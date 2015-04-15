package com.rokannon.project.FFParticleSystemDesigner.model
{
    import flash.filesystem.File;

    import starling.textures.Texture;

    public class ParticleModel
    {
        public var particleDirectory:File;
        public var particlePex:XML;
        public var particleAtlasXml:XML;
        public var particleTexture:Texture;
        public var appendFromObject:Object;
    }
}