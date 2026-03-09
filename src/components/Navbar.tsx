import React from 'react';
import { GraduationCap, Settings, Upload, LogOut, CircleHelp, BookOpen } from 'lucide-react';
import { supabase } from '../supabase';

interface NavbarProps {
  userEmail: string;
  syncStatus: 'idle' | 'saving' | 'saved' | 'error';
  onOpenSettings: () => void;
  onImport: (html: string) => void;
  onReset: () => void;
  onOpenHelp: () => void;
}

export const Navbar: React.FC<NavbarProps> = ({ userEmail, syncStatus, onOpenSettings, onImport, onOpenHelp }) => {
  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
  
    const reader = new FileReader();
    reader.onload = (event) => {
      const htmlContent = event.target?.result as string;
      onImport(htmlContent);
    };
    reader.readAsText(file);
    e.target.value = '';
  };

  const handleLogout = async () => {
    if (!supabase) return;
    await supabase.auth.signOut();
    // onReset(); // 移除這行，不要觸發重置警告
    window.location.reload(); // 直接重新整理頁面，App 會自動回到登入畫面
  };

  return (
    <nav
      className="bg-white/95 backdrop-blur sticky top-0 z-20 border-b border-slate-200 shadow-sm"
      style={{ paddingTop: 'env(safe-area-inset-top)' }}
    >
      <div className="max-w-7xl mx-auto px-3 sm:px-6 lg:px-8 py-3 sm:py-0">
        <div className="flex flex-col gap-3 sm:h-16 sm:flex-row sm:items-center sm:justify-between">
          <div className="min-w-0 flex items-center gap-3">
            <GraduationCap className="w-7 h-7 sm:w-8 sm:h-8 text-blue-600 flex-shrink-0" />
            <div className="min-w-0">
              <div className="flex items-center gap-2">
                <span className="text-lg sm:text-xl font-bold text-gray-900 truncate">修課規劃助手</span>
                {syncStatus === 'saving' && <span className="text-xs text-gray-400 hidden sm:inline">儲存中...</span>}
                {syncStatus === 'saved' && <span className="text-xs text-green-500 hidden sm:inline">已儲存</span>}
              </div>
              <div className="flex items-center gap-2 sm:hidden">
                <span className="text-xs text-slate-500 truncate">{userEmail}</span>
                {syncStatus === 'saving' && <span className="text-[11px] text-gray-400">儲存中...</span>}
                {syncStatus === 'saved' && <span className="text-[11px] text-green-500">已儲存</span>}
              </div>
            </div>
          </div>

          <div className="flex items-center gap-2 sm:gap-4">
            <span className="text-sm text-gray-600 hidden sm:block truncate max-w-44">{userEmail}</span>
            <div className="grid grid-cols-5 sm:flex items-center gap-2 w-full sm:w-auto">
              <button
                onClick={onOpenSettings}
                className="flex items-center justify-center gap-2 px-3 py-2 text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
                title="設定門檻"
              >
                <Settings className="w-4 h-4" />
                <span className="hidden md:inline">設定門檻</span>
              </button>

              <label
                className="flex items-center justify-center gap-2 px-3 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors cursor-pointer"
                title="匯入成績"
              >
                <Upload className="w-4 h-4" />
                <span className="hidden md:inline">匯入成績</span>
                <input
                  type="file"
                  accept=".html"
                  onChange={handleFileUpload}
                  className="hidden"
                />
              </label>

              <button
                onClick={() => alert('匯入說明：\n\n【成績查詢系統】(建議 - 包含成績資訊):\n1. 前往臺科大成績查詢系統 (https://stuinfosys.ntust.edu.tw/StuScoreQueryServ/StuScoreQuery)\n2. 在頁面上點擊右鍵，選擇「另存新檔」或「網頁儲存為...」\n3. 下載 .html 檔案並上傳\n\n【選課清單】(快速選課規劃):\n1. 前往臺科大選課系統 (/ChooseList/D03/D03)\n2. 在頁面上點擊右鍵，選擇「另存新檔」或「網頁儲存為...」\n3. 下載 .html 檔案並上傳\n\n兩種格式都支援！選擇適合您的匯入方式。')}
                className="flex items-center justify-center p-2 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                title="匯入說明"
              >
                <CircleHelp className="w-5 h-5" />
              </button>

              <button
                onClick={onOpenHelp}
                className="flex items-center justify-center p-2 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors"
                title="功能導覽"
              >
                <BookOpen className="w-5 h-5" />
              </button>

              <button
                onClick={handleLogout}
                className="flex items-center justify-center gap-2 px-3 py-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                title="登出"
              >
                <LogOut className="w-4 h-4" />
                <span className="hidden md:inline">登出</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </nav>
  );
};
