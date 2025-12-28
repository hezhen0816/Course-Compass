import React from 'react';
import { Activity, BookOpen } from 'lucide-react';
import { ProgressBar } from './ProgressBar';
import type { AppData } from '../types';

interface SidebarProps {
  data: AppData;
  stats: any; // Define stats type properly if possible
}

export const Sidebar: React.FC<SidebarProps> = ({ data, stats }) => {
  return (
    <div className="lg:col-span-3 space-y-6">
      <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-5">
        <h2 className="text-lg font-bold text-slate-800 mb-4 flex items-center">
          <Activity className="h-5 w-5 mr-2 text-blue-500" />
          畢業門檻進度
        </h2>
        
        <ProgressBar 
          label="總學分" 
          current={stats.total} 
          target={data.targets.total} 
          colorClass="bg-blue-500" 
        />
        
        <div className="border-t border-slate-100 my-4"></div>
        
        <h3 className="text-sm font-semibold text-slate-500 mb-3 uppercase tracking-wider">共同必修</h3>
        
        <ProgressBar 
          label="國文" 
          current={stats.chinese} 
          target={data.targets.chinese} 
          colorClass="bg-orange-500" 
        />
        <ProgressBar 
          label="英文" 
          current={stats.english} 
          target={data.targets.english} 
          colorClass="bg-indigo-500" 
        />
        <ProgressBar 
          label="社會實踐" 
          current={stats.social} 
          target={data.targets.social} 
          colorClass="bg-yellow-500" 
        />
        <ProgressBar 
          label="體育 (學期數)" 
          current={stats.pe_semesters} 
          target={data.targets.pe_semesters} 
          isCount={true}
          colorClass="bg-green-500" 
          subLabel="大一至大三"
        />

        <div className="border-t border-slate-100 my-4"></div>

        <h3 className="text-sm font-semibold text-slate-500 mb-3 uppercase tracking-wider">通識領域 (需修 {data.targets.gen_ed} 學分)</h3>
        <ProgressBar 
          label="通識學分" 
          current={stats.gen_ed} 
          target={data.targets.gen_ed} 
          colorClass="bg-purple-500" 
        />
        
        <div className="mt-3 bg-purple-50 p-3 rounded-lg">
          <p className="text-xs text-purple-700 font-medium mb-2">已修向度 (A~F):</p>
          <div className="flex flex-wrap gap-1">
            {['A','B','C','D','E','F'].map(dim => (
              <span 
                key={dim}
                className={`text-xs px-2 py-1 rounded border ${
                  stats.genEdDimensions.has(dim) 
                    ? 'bg-purple-500 text-white border-purple-600' 
                    : 'bg-white text-gray-400 border-gray-200'
                }`}
              >
                {dim}
              </span>
            ))}
          </div>
        </div>

      </div>

      <div className="bg-white rounded-xl shadow-sm border border-slate-200 p-5">
          <h2 className="text-lg font-bold text-slate-800 mb-2 flex items-center">
          <BookOpen className="h-5 w-5 mr-2 text-red-500" />
          系所課程
        </h2>
        <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">系必修學分</span>
              <span className="font-bold">{stats.compulsory}</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">選修學分</span>
              <span className="font-bold">{stats.elective}</span>
            </div>
        </div>
      </div>
    </div>
  );
};
