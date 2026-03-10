# 修課規劃助手

同一個 repo 內同時保留兩條產品線：

- `Web`：專注課程規劃、課程匯入、學分門檻管理與詳細資訊編修。
- `iOS`：原生 SwiftUI App，承接首頁摘要、課表、待辦、提醒與手機版學分規劃。

這樣的分工可以避免 Web 與 iOS 互相拖累，同時保留最適合各自裝置的操作模式。

## 產品邊界

### Web 版

- React + Vite 單頁應用。
- 保留 Supabase 登入與同步。
- 保留 HTML 匯入、八學期編排、學分統計、課程詳細資訊與成績試算。
- 不再承接首頁摘要、待辦、提醒或手機導向課表。

### iOS 版

- `iOS 17+` 原生 SwiftUI。
- 課表同步改由 Python 後端登入校務系統，並可寫入 Supabase。
- 以 `TabView` 提供首頁、課表、學分規劃、設定四個原生分頁。

### Python 後端

- `FastAPI` 提供課表同步 API。
- 可用校務帳密登入 `https://courseselection.ntust.edu.tw/` 抓取課表。
- 可將同步結果 upsert 到 Supabase `schedule_sync_snapshots`。

## 開發指令

### Web

```bash
npm run web:dev
npm run web:build
```

`dev` / `build` 目前仍等同於 Web 版指令。

### iOS

```bash
npm run ios:open
npm run ios:build
```

- `ios:open`：直接開啟 `ios/App/App.xcodeproj`
- `ios:build`：用 `xcodebuild` 驗證原生 iOS target 可編譯

### Backend

```bash
cd /Users/hezhen/Project/course_planner
python3 -m venv .venv
.venv/bin/pip install -r backend/requirements.txt
cp .env.example .env
npm run backend:dev
```

需要的環境變數：

```bash
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...
SUPABASE_URL=...
SUPABASE_SERVICE_ROLE_KEY=...
NTUST_VERIFY_SSL=false
```

說明：

- `VITE_SUPABASE_*` 給 Web 前端使用
- `SUPABASE_SERVICE_ROLE_KEY` 只給 Python 後端使用，不要放進前端或 iOS
- Web 與 iOS 可共用同一個 Supabase 專案，目前學分規劃資料共用 `public.user_data`

Supabase table schema 在 [backend/supabase_schema.sql](/Users/hezhen/Project/course_planner/backend/supabase_schema.sql)。

API：

- `POST /api/schedule/sync`：登入校務、抓課表、可選擇寫入 Supabase
- `GET /api/schedule/{profile_key}`：從 Supabase 讀取最新課表快照

## 建議維護方式

1. Web 與 iOS 分開定義產品責任，不共用畫面層。
2. 若未來要串接真資料，優先抽出共用的資料規則與 mapping，不共用 UI 狀態。
3. Web 端只處理大螢幕最有價值的規劃流程；行動版需求直接落在原生 iOS。

---

Developed by Hezhen
