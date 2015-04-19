package com.rokannon.project.FFParticleSystemDesigner.controller.enum
{
    import com.rokannon.core.StaticClassBase;

    public class ErrorMessage extends StaticClassBase
    {
        public static const APPLICATION_FOLDER_CORRUPTED:String = "Program folder corrupted.\nTry to reinstall application.";
        public static const BAD_CONFIG:String = "Error loading or parsing application config.";
        public static const BAD_PARTICLE_FOLDER:String = "There was error opening particle system directory.";
        public static const BAD_PEX_FILE:String = "Error loading or parsing pex file.";
        public static const BAD_ATLAS_XML:String = "Error loading or parsing atlas xml.";
        public static const BAD_TEXTURE:String = "Error loading texture(s).";
    }
}