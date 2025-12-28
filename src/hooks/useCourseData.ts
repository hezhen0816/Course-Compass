import { useState, useEffect } from 'react';
import { supabase } from '../supabase';
import type { AppData } from '../types';
import { INITIAL_SEMESTERS } from '../constants';

export function useCourseData(session: any) {
  const [data, setData] = useState<AppData>({
    semesters: INITIAL_SEMESTERS,
    targets: {
      total: 133,
      chinese: 6,
      english: 12,
      gen_ed: 15,
      pe_semesters: 6,
      social: 1,
    }
  });
  const [syncStatus, setSyncStatus] = useState<'idle' | 'saving' | 'saved' | 'error'>('idle');
  const [isLoading, setIsLoading] = useState(true);

  // Load data
  useEffect(() => {
    if (!session || !supabase) {
      setIsLoading(false);
      return;
    }
    
    const loadUserData = async () => {
      if (!supabase) return;
      setSyncStatus('saving');
      const { data: userData, error } = await supabase
        .from('user_data')
        .select('content')
        .eq('user_id', session.user.id)
        .single();

      if (error && error.code !== 'PGRST116') {
        console.error('Error loading data:', error);
      }

      if (userData && userData.content) {
        setData(userData.content);
      }
      setSyncStatus('idle');
      setIsLoading(false);
    };

    loadUserData();
  }, [session]);

  // Save data
  const saveUserData = async (newData: AppData) => {
    if (!session || !supabase) return;
    setSyncStatus('saving');
    
    // Check existing
    const { data: existingData } = await supabase
      .from('user_data')
      .select('id')
      .eq('user_id', session.user.id)
      .single();

    let error;
    if (existingData) {
      const { error: updateError } = await supabase
        .from('user_data')
        .update({ content: newData, updated_at: new Date() })
        .eq('user_id', session.user.id);
      error = updateError;
    } else {
      const { error: insertError } = await supabase
        .from('user_data')
        .insert([{ user_id: session.user.id, content: newData }]);
      error = insertError;
    }

    if (error) {
      console.error('Error saving data:', error);
      setSyncStatus('error');
    } else {
      setSyncStatus('saved');
      setTimeout(() => setSyncStatus('idle'), 2000);
    }
  };

  // Auto-save effect
  useEffect(() => {
    if (!session) return;
    const timer = setTimeout(() => {
      saveUserData(data);
    }, 2000);
    return () => clearTimeout(timer);
  }, [data, session]);

  return { data, setData, syncStatus, isLoading };
}
