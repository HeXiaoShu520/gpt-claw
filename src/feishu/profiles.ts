import { mkdir, readFile, rename, writeFile } from "node:fs/promises";
import { randomUUID } from "node:crypto";
import { dirname, join } from "node:path";
import { log as logger } from "../shared/log.ts";

export interface LarkUserProfile {
  name: string; // 中文名（查不到为空串）
  en_name: string; // 英文名（查不到为空串）
  department_name: string[]; // 已缓存的部门路径（查不到为空数组）
  /** 信息查询或更新时间（ISO 8601） */
  updatedAt: string;
}

/** 单次查询通道的返回：命中的资料字段 */
export interface ProfileName {
  name?: string;
  en_name?: string;
  department_name?: string[];
}

/** 所有用户资料的缓存结构（以 openId 为键） */
interface UserProfileCache {
  [openId: string]: LarkUserProfile;
}

/** Local profile storage only; API lookup belongs to inbound normalization, with no CLI/auth calls. */
export class UserProfiles {
  private readonly cacheFilePath: string;
  private cache: UserProfileCache = {};
  private loadPromise?: Promise<void>;
  private writeQueue: Promise<void> = Promise.resolve();
  constructor(appId: string, dataDir = join(process.cwd(), ".data", "users")) {
    this.cacheFilePath = join(dataDir, `${appId}_users.json`);
  }

  /** 读取已有资料；未登录或未缓存时只返回 openId 兜底，不发起跨用户查询。 */
  async getUserProfile(openId: string): Promise<LarkUserProfile> {
    await this.loadCache();
    return (
      this.cache[openId] ?? {
        name: "",
        en_name: "",
        department_name: [],
        updatedAt: "",
      }
    );
  }

  private async loadCache(): Promise<void> {
    this.loadPromise ??= (async () => {
      try {
        this.cache = JSON.parse(
          await readFile(this.cacheFilePath, "utf8"),
        ) as UserProfileCache;
      } catch (error) {
        if ((error as NodeJS.ErrnoException).code !== "ENOENT")
          logger.warn(`[Profiles] 用户缓存不可读，将重新查询: ${String(error)}`);
        this.cache = {};
      }
    })();
    await this.loadPromise;
  }

  private async saveCache(): Promise<void> {
    const task = this.writeQueue.then(async () => {
      await mkdir(dirname(this.cacheFilePath), { recursive: true });
      const temp = `${this.cacheFilePath}.${randomUUID()}.tmp`;
      await writeFile(temp, `${JSON.stringify(this.cache, null, 2)}\n`, "utf8");
      await rename(temp, this.cacheFilePath);
    });
    this.writeQueue = task.catch(() => {});
    await task;
  }

  /**
   * Merge profiles provided by actual message mentions or the fixed bot API lookup.
   */
  async putProfile(openId: string, profile: ProfileName): Promise<void> {
    await this.loadCache();
    const prev = this.cache[openId];
    this.cache[openId] = {
      name: profile.name ?? prev?.name ?? "",
      en_name: profile.en_name ?? prev?.en_name ?? "",
      department_name: profile.department_name ?? prev?.department_name ?? [],
      updatedAt: new Date().toISOString(),
    };
    await this.saveCache();
  }
}
