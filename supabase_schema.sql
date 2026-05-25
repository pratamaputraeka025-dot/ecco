// lib/utils/supabase_client.dart
//
// File ini menyimpan konfigurasi koneksi ke Supabase.
// Ganti SUPABASE_URL dan SUPABASE_ANON_KEY dengan milikmu!
//
// Cara dapat credentials:
//   1. Buka https://supabase.com → project kamu
//   2. Settings → API
//   3. Copy "Project URL" dan "anon public" key

import 'package:supabase_flutter/supabase_flutter.dart';

// ── GANTI 2 BARIS INI ──────────────────────────────────────────
const String supabaseUrl    = 'https://gtcbtrncfvztunylpirl.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd0Y2J0cm5jZnZ6dHVueWxwaXJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0MDQ3NjcsImV4cCI6MjA5Mzk4MDc2N30.RvEKKD1_Roo94GjEVrfyfhMXFIm5SeXWtg9I5KKl0CM';
// ───────────────────────────────────────────────────────────────

/// Shortcut global untuk mengakses Supabase client
/// Penggunaan: `supabase.from('products').select()`
final supabase = Supabase.instance.client;