export interface DesktopMessage {
  source: "desktop";
  message_id: string;
  chat_id: string;
  text: string;
  screenShareId?: string;
  images: { path: string }[];
  files: { path: string }[];
}
