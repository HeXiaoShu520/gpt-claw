"""
VRM 1.0 → 标准 GLB 转换器
将 MToon/KHR_materials_unlit 材质转成 PBR，剥掉 VRM 专有扩展，
输出 Qt Quick 3D 可直接加载的标准 glTF 2.0 GLB。
"""
import struct
import json
import copy
import sys
import os

# MToon 材质转 PBR 参数
# MToon 是卡通渲染，roughness 偏高，metallic=0
MTOON_ROUGHNESS = {
    'SKIN': 0.85,
    'HAIR': 0.75,
    'EYE':  0.15,
    'FACE': 0.80,
    'CLOTH': 0.70,
    'SHOES': 0.65,
    'DEFAULT': 0.72,
}

# 需要剥掉的 VRM 专有扩展（Qt 不认识这些）
REMOVE_EXTENSIONS = {
    'VRMC_vrm',
    'VRMC_springBone',
    'VRMC_springBone_extended_collider',
    'VRMC_node_constraint',
    'VRMC_materials_mtoon',
    'KHR_materials_unlit',
}

def guess_roughness(mat_name: str) -> float:
    """根据材质名称猜测合适的 roughness 值"""
    name_upper = mat_name.upper()
    for key, val in MTOON_ROUGHNESS.items():
        if key in name_upper:
            return val
    return MTOON_ROUGHNESS['DEFAULT']

def convert_material(mat: dict) -> dict:
    """把单个 MToon/unlit 材质转成标准 PBR 材质"""
    m = copy.deepcopy(mat)
    name = m.get('name', '')
    roughness = guess_roughness(name)

    # 保留 pbrMetallicRoughness，补全缺失字段
    pbr = m.get('pbrMetallicRoughness', {})
    # baseColorFactor 默认白色
    if 'baseColorFactor' not in pbr:
        pbr['baseColorFactor'] = [1.0, 1.0, 1.0, 1.0]
    pbr['metallicFactor'] = 0.0
    pbr['roughnessFactor'] = roughness
    m['pbrMetallicRoughness'] = pbr

    # 从 MToon 里提取阴影色作为 emissiveFactor 微弱补偿（让卡通感保留一点）
    mtoon = m.get('extensions', {}).get('VRMC_materials_mtoon', {})
    shade = mtoon.get('shadeColorFactor')
    if shade and len(shade) >= 3:
        # 用阴影色的 1/6 作为极微弱自发光，补偿 unlit 到 PBR 的亮度损失
        emit = [min(c * 0.12, 0.08) for c in shade[:3]]
        m['emissiveFactor'] = emit

    # 法线贴图：MToon 里的 normalTexture 直接保留
    # （已在 pbrMetallicRoughness 外层，glTF 标准支持）

    # 剥掉所有 VRM/MToon 扩展
    if 'extensions' in m:
        for ext in list(m['extensions'].keys()):
            if ext in REMOVE_EXTENSIONS:
                del m['extensions'][ext]
        if not m['extensions']:
            del m['extensions']

    # 剥掉 extras 里的 VRM 私有数据（可选保留）
    m.pop('extras', None)

    return m

def convert_vrm(src_path: str, dst_path: str):
    print(f'读取: {src_path}')
    with open(src_path, 'rb') as f:
        data = f.read()

    # --- 解析 GLB 结构 ---
    magic   = data[0:4]
    version = struct.unpack_from('<I', data, 4)[0]
    assert magic == b'glTF' and version == 2, '不是合法的 glTF 2.0 文件'

    # Chunk 0: JSON
    json_len  = struct.unpack_from('<I', data, 12)[0]
    json_type = data[16:20]
    assert json_type == b'JSON', 'Chunk 0 不是 JSON'
    json_start = 20
    json_end   = json_start + json_len
    gltf = json.loads(data[json_start:json_end])

    # Chunk 1: BIN（可能不存在）
    bin_data = b''
    if json_end + 8 <= len(data):
        bin_len  = struct.unpack_from('<I', data, json_end)[0]
        bin_type = data[json_end+4:json_end+8]
        if bin_type == b'BIN\x00':
            bin_data = data[json_end+8 : json_end+8+bin_len]

    print(f'  节点={len(gltf.get("nodes",[]))}, '
          f'网格={len(gltf.get("meshes",[]))}, '
          f'蒙皮={len(gltf.get("skins",[]))}, '
          f'动画={len(gltf.get("animations",[]))}, '
          f'材质={len(gltf.get("materials",[]))}')

    # --- 转换材质 ---
    if 'materials' in gltf:
        converted = [convert_material(m) for m in gltf['materials']]
        gltf['materials'] = converted
        print(f'  已转换 {len(converted)} 个材质 (MToon → PBR)')

    # --- 清理顶层扩展声明 ---
    for key in ('extensionsUsed', 'extensionsRequired'):
        if key in gltf:
            gltf[key] = [e for e in gltf[key] if e not in REMOVE_EXTENSIONS]
            if not gltf[key]:
                del gltf[key]

    # --- 清理节点上的 VRM 扩展 ---
    for node in gltf.get('nodes', []):
        if 'extensions' in node:
            for ext in list(node['extensions'].keys()):
                if ext in REMOVE_EXTENSIONS:
                    del node['extensions'][ext]
            if not node['extensions']:
                del node['extensions']

    # --- 清理顶层 extensions ---
    if 'extensions' in gltf:
        for ext in list(gltf['extensions'].keys()):
            if ext in REMOVE_EXTENSIONS:
                del gltf['extensions'][ext]
        if not gltf['extensions']:
            del gltf['extensions']

    gltf.pop('extras', None)

    # --- 重新序列化 JSON chunk ---
    json_bytes = json.dumps(gltf, separators=(',', ':'), ensure_ascii=False).encode('utf-8')
    # JSON chunk 必须 4 字节对齐，用空格填充
    pad = (4 - len(json_bytes) % 4) % 4
    json_bytes += b' ' * pad

    # --- 组装新 GLB ---
    # 总长度 = 12 (header) + 8 (json chunk header) + json + 8 (bin chunk header) + bin
    has_bin = len(bin_data) > 0
    total = 12 + 8 + len(json_bytes)
    if has_bin:
        bin_pad = (4 - len(bin_data) % 4) % 4
        bin_data_padded = bin_data + b'\x00' * bin_pad
        total += 8 + len(bin_data_padded)

    out = bytearray()
    # GLB header
    out += b'glTF'
    out += struct.pack('<I', 2)      # version
    out += struct.pack('<I', total)  # total length

    # JSON chunk
    out += struct.pack('<I', len(json_bytes))
    out += b'JSON'
    out += json_bytes

    # BIN chunk
    if has_bin:
        out += struct.pack('<I', len(bin_data_padded))
        out += b'BIN\x00'
        out += bin_data_padded

    with open(dst_path, 'wb') as f:
        f.write(out)

    size_mb = len(out) / 1024 / 1024
    print(f'写出: {dst_path}  ({size_mb:.1f} MB)')
    print('完成！')

if __name__ == '__main__':
    src = sys.argv[1] if len(sys.argv) > 1 else 'AvatarSample_A.vrm'
    dst = sys.argv[2] if len(sys.argv) > 2 else src.rsplit('.', 1)[0] + '_qt.glb'
    convert_vrm(src, dst)
