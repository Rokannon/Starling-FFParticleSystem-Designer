package com.rokannon.project.FFParticleSystemDesigner.model
{
    import com.rokannon.core.command.CommandExecutor;

    import starling.core.Starling;

    public class ApplicationModel
    {
        public const commandExecutor:CommandExecutor = new CommandExecutor();
        public const fileModel:FileModel = new FileModel();
        public const particleModel:ParticleModel = new ParticleModel();
        public var starlingInstance:Starling;
        public var firstRun:Boolean = false;

        public function ApplicationModel()
        {
        }
    }
}