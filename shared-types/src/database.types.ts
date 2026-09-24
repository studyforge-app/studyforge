export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      card_review: {
        Row: {
          flashcard_id: string
          id: string
          knew: boolean
          reviewed_at: string
          session_id: string
        }
        Insert: {
          flashcard_id: string
          id?: string
          knew: boolean
          reviewed_at?: string
          session_id: string
        }
        Update: {
          flashcard_id?: string
          id?: string
          knew?: boolean
          reviewed_at?: string
          session_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_card_review_flashcard"
            columns: ["flashcard_id"]
            isOneToOne: false
            referencedRelation: "flashcard"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_card_review_session"
            columns: ["session_id"]
            isOneToOne: false
            referencedRelation: "study_session"
            referencedColumns: ["id"]
          },
        ]
      }
      card_state: {
        Row: {
          created_at: string
          due_at: string
          flashcard_id: string
          last_result: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          due_at?: string
          flashcard_id: string
          last_result?: string | null
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          due_at?: string
          flashcard_id?: string
          last_result?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_card_state_flashcard"
            columns: ["flashcard_id"]
            isOneToOne: false
            referencedRelation: "flashcard"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_card_state_user"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profile"
            referencedColumns: ["id"]
          },
        ]
      }
      chunk: {
        Row: {
          attempts: number
          created_at: string
          document_id: string
          id: string
          position: number
          source_ref: string | null
          status: string
          text: string
          updated_at: string
        }
        Insert: {
          attempts?: number
          created_at?: string
          document_id: string
          id?: string
          position: number
          source_ref?: string | null
          status?: string
          text: string
          updated_at?: string
        }
        Update: {
          attempts?: number
          created_at?: string
          document_id?: string
          id?: string
          position?: number
          source_ref?: string | null
          status?: string
          text?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_chunk_document"
            columns: ["document_id"]
            isOneToOne: false
            referencedRelation: "document"
            referencedColumns: ["id"]
          },
        ]
      }
      document: {
        Row: {
          attempts: number
          created_at: string
          error_message: string | null
          file_hash: string
          file_path: string
          file_type: string
          id: string
          locked_at: string | null
          page_count: number | null
          status: string
          updated_at: string
        }
        Insert: {
          attempts?: number
          created_at?: string
          error_message?: string | null
          file_hash: string
          file_path: string
          file_type: string
          id?: string
          locked_at?: string | null
          page_count?: number | null
          status?: string
          updated_at?: string
        }
        Update: {
          attempts?: number
          created_at?: string
          error_message?: string | null
          file_hash?: string
          file_path?: string
          file_type?: string
          id?: string
          locked_at?: string | null
          page_count?: number | null
          status?: string
          updated_at?: string
        }
        Relationships: []
      }
      flashcard: {
        Row: {
          back: string
          chunk_id: string
          created_at: string
          deleted_at: string | null
          edited: boolean
          front: string
          id: string
          source_ref: string | null
          updated_at: string
        }
        Insert: {
          back: string
          chunk_id: string
          created_at?: string
          deleted_at?: string | null
          edited?: boolean
          front: string
          id?: string
          source_ref?: string | null
          updated_at?: string
        }
        Update: {
          back?: string
          chunk_id?: string
          created_at?: string
          deleted_at?: string | null
          edited?: boolean
          front?: string
          id?: string
          source_ref?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_flashcard_chunk"
            columns: ["chunk_id"]
            isOneToOne: false
            referencedRelation: "chunk"
            referencedColumns: ["id"]
          },
        ]
      }
      material: {
        Row: {
          created_at: string
          document_id: string
          id: string
          module_id: string
          title: string | null
        }
        Insert: {
          created_at?: string
          document_id: string
          id?: string
          module_id: string
          title?: string | null
        }
        Update: {
          created_at?: string
          document_id?: string
          id?: string
          module_id?: string
          title?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_material_document"
            columns: ["document_id"]
            isOneToOne: false
            referencedRelation: "document"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_material_module"
            columns: ["module_id"]
            isOneToOne: false
            referencedRelation: "module"
            referencedColumns: ["id"]
          },
        ]
      }
      module: {
        Row: {
          course_id: string | null
          created_at: string
          exam_date: string | null
          id: string
          name: string
          owner_id: string
          updated_at: string
        }
        Insert: {
          course_id?: string | null
          created_at?: string
          exam_date?: string | null
          id?: string
          name: string
          owner_id: string
          updated_at?: string
        }
        Update: {
          course_id?: string | null
          created_at?: string
          exam_date?: string | null
          id?: string
          name?: string
          owner_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_module_owner"
            columns: ["owner_id"]
            isOneToOne: false
            referencedRelation: "profile"
            referencedColumns: ["id"]
          },
        ]
      }
      profile: {
        Row: {
          avatar_url: string | null
          created_at: string
          current_streak: number
          display_name: string | null
          id: string
          last_study_date: string | null
          longest_streak: number
          timezone: string
          updated_at: string
          xp_total: number
        }
        Insert: {
          avatar_url?: string | null
          created_at?: string
          current_streak?: number
          display_name?: string | null
          id: string
          last_study_date?: string | null
          longest_streak?: number
          timezone?: string
          updated_at?: string
          xp_total?: number
        }
        Update: {
          avatar_url?: string | null
          created_at?: string
          current_streak?: number
          display_name?: string | null
          id?: string
          last_study_date?: string | null
          longest_streak?: number
          timezone?: string
          updated_at?: string
          xp_total?: number
        }
        Relationships: []
      }
      quiz_answer: {
        Row: {
          answered_at: string
          chosen_index: number
          id: string
          is_correct: boolean
          question_id: string
          session_id: string
        }
        Insert: {
          answered_at?: string
          chosen_index: number
          id?: string
          is_correct: boolean
          question_id: string
          session_id: string
        }
        Update: {
          answered_at?: string
          chosen_index?: number
          id?: string
          is_correct?: boolean
          question_id?: string
          session_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_quiz_answer_question"
            columns: ["question_id"]
            isOneToOne: false
            referencedRelation: "quiz_question"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_quiz_answer_session"
            columns: ["session_id"]
            isOneToOne: false
            referencedRelation: "study_session"
            referencedColumns: ["id"]
          },
        ]
      }
      quiz_question: {
        Row: {
          chunk_id: string
          correct_index: number
          created_at: string
          deleted_at: string | null
          explanation: string | null
          id: string
          options: Json
          question: string
          source_ref: string | null
          updated_at: string
        }
        Insert: {
          chunk_id: string
          correct_index: number
          created_at?: string
          deleted_at?: string | null
          explanation?: string | null
          id?: string
          options: Json
          question: string
          source_ref?: string | null
          updated_at?: string
        }
        Update: {
          chunk_id?: string
          correct_index?: number
          created_at?: string
          deleted_at?: string | null
          explanation?: string | null
          id?: string
          options?: Json
          question?: string
          source_ref?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_quiz_question_chunk"
            columns: ["chunk_id"]
            isOneToOne: false
            referencedRelation: "chunk"
            referencedColumns: ["id"]
          },
        ]
      }
      study_session: {
        Row: {
          completed: boolean
          finished_at: string | null
          id: string
          module_id: string
          started_at: string
          type: string
          user_id: string
        }
        Insert: {
          completed?: boolean
          finished_at?: string | null
          id?: string
          module_id: string
          started_at?: string
          type: string
          user_id: string
        }
        Update: {
          completed?: boolean
          finished_at?: string | null
          id?: string
          module_id?: string
          started_at?: string
          type?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_study_session_module"
            columns: ["module_id"]
            isOneToOne: false
            referencedRelation: "module"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_study_session_user"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profile"
            referencedColumns: ["id"]
          },
        ]
      }
      xp_event: {
        Row: {
          amount: number
          created_at: string
          id: string
          reason: string
          session_id: string | null
          user_id: string
        }
        Insert: {
          amount: number
          created_at?: string
          id?: string
          reason: string
          session_id?: string | null
          user_id: string
        }
        Update: {
          amount?: number
          created_at?: string
          id?: string
          reason?: string
          session_id?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_xp_event_session"
            columns: ["session_id"]
            isOneToOne: false
            referencedRelation: "study_session"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_xp_event_user"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profile"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      user_can_access_document: { Args: { doc_id: string }; Returns: boolean }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {},
  },
} as const
