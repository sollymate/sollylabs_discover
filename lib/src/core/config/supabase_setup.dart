import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSetup {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://xxrsdsxpunwytsfizujp.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4cnNkc3hwdW53eXRzZml6dWpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc0NTQ5NjgsImV4cCI6MjA1MzAzMDk2OH0.39sq7-uHSVPcKN6fzGzLOPt4pUXi3bnn-F-eT6UFLfw',
    );

    if (kDebugMode) {
      print("✅ Supabase initialized successfully.");
    }
  }
}
