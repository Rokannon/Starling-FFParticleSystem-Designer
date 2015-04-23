package com.rokannon.project.FFParticleSystemDesigner.model
{
    import com.rokannon.core.Broadcaster;
    import com.rokannon.math.utils.getMax;

    import starling.animation.IAnimatable;

    public class ParticleUpdateModel implements IAnimatable
    {
        public const eventUpdated:Broadcaster = new Broadcaster(this);

        private var _updateDelay:Number = 0;
        private var _delayTimer:Number = 0;

        public function ParticleUpdateModel()
        {
        }

        public function setUpdateDelay(value:Number):void
        {
            value = getMax(value, 0);
            _updateDelay = value;
            _delayTimer = 0;
        }

        public function advanceTime(time:Number):void
        {
            if (_updateDelay == 0)
                return;
            _delayTimer += time;
            if (_delayTimer > _updateDelay)
                eventUpdated.broadcast();
            while (_delayTimer > _updateDelay)
                _delayTimer -= _updateDelay;
        }
    }
}