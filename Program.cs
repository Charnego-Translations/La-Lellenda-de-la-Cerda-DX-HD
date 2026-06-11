using System;

namespace ProjectZ
{
    public static class Program
    {
        static void Main(string[] args)
        {
            var editorMode = false;
            var loadFirstSave = false;

            foreach (var arg in args)
            {
                if (arg == "editor")
                    editorMode = true;
                else if (arg == "loadSave")
                    loadFirstSave = true;
            }

            // Set up cross-platform audio output
            Game1.GbsPlayer.SetAudioOutput(new GbsPlayer.OpenALOutput(44100));

#if !DEBUG
            try
#endif
            {
                using var game = new Game1(editorMode, loadFirstSave);
                game.Run();
            }
#if !DEBUG
            catch (Exception exception)
            {
               Console.Error.WriteLine("Fatal error: {0}\n{1}", exception.Message, exception.StackTrace);
               throw;
            }
#endif
        }
    }
}