export type CourseCategory = 
  | 'compulsory'   // 系必修
  | 'elective'     // 系選修/一般選修
  | 'chinese'      // 國文
  | 'english'      // 英文
  | 'gen_ed'       // 通識
  | 'pe'           // 體育
  | 'social'       // 社會實踐
  | 'other'        // 其他
  | 'unclassified'; // 未歸類

export type GenEdDimension = 'A' | 'B' | 'C' | 'D' | 'E' | 'F' | 'None';

export interface Course {
  id: string;
  name: string;
  credits: number;
  category: CourseCategory;
  dimension?: GenEdDimension; // For General Education
  grade?: string;
}

export interface Semester {
  id: string;
  name: string;
  courses: Course[];
}

export interface AppData {
  semesters: Semester[];
  targets: {
    total: number;
    chinese: number;
    english: number;
    gen_ed: number;
    pe_semesters: number;
    social: number;
  };
}
