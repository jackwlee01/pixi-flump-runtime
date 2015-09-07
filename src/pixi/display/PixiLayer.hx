package pixi.display;

import pixi.core.display.Container;
import pixi.core.math.Point;


class PixiLayer extends Container{

    public var skew = new Point();

    override public function updateTransform(){
        untyped __js__('
            if (!this.visible)
            {
                return;
            }');


        untyped __js__('
             // create some matrix refs for easy access
            var pt = this.parent.worldTransform;
            var wt = this.worldTransform;

            // temporary matrix variables
            var a, b, c, d, tx, ty,
                rotY = this.rotation + this.skew.y,
                rotX = this.rotation + this.skew.x;
        ');

        untyped __js__('
            // so if rotation is between 0 then we can simplify the multiplication process..
            if (rotY % (Math.PI*2) || rotX % (Math.PI*2))
            {
                // check to see if the rotation is the same as the previous render. This means we only need to use sin and cos when rotation actually changes
                if (rotX !== this._cachedRotX || rotY !== this._cachedRotY)
                {
                    // cache new values
                    this._cachedRotX = rotX;
                    this._cachedRotY = rotY;

                    // recalculate expensive ops
                    this._crA = Math.cos(rotY);
                    this._srB = Math.sin(rotY);

                    this._srC = Math.sin(-rotX);
                    this._crD = Math.cos(rotX);
                }

                // get the matrix values of the displayobject based on its transform properties..
                a  = this._crA * this.scale.x;
                b  = this._srB * this.scale.x;
                c  = this._srC * this.scale.y;
                d  = this._crD * this.scale.y;
                tx = this.position.x;
                ty = this.position.y;

                // check for pivot.. not often used so geared towards that fact!
                //if (this.pivot.x || this.pivot.y)
                //{
                    tx -= this.pivot.x * a + this.pivot.y * c;
                    ty -= this.pivot.x * b + this.pivot.y * d;
                //}

                // concat the parent matrix with the objects transform.
                wt.a  = a  * pt.a + b  * pt.c;
                wt.b  = a  * pt.b + b  * pt.d;
                wt.c  = c  * pt.a + d  * pt.c;
                wt.d  = c  * pt.b + d  * pt.d;
                wt.tx = tx * pt.a + ty * pt.c + pt.tx;
                wt.ty = tx * pt.b + ty * pt.d + pt.ty;
            }
            else
            {
                // lets do the fast version as we know there is no rotation..
                a  = this.scale.x;
                d  = this.scale.y;

                tx = this.position.x - this.pivot.x * a;
                ty = this.position.y - this.pivot.y * d;

                wt.a  = a  * pt.a;
                wt.b  = a  * pt.b;
                wt.c  = d  * pt.c;
                wt.d  = d  * pt.d;
                wt.tx = tx * pt.a + ty * pt.c + pt.tx;
                wt.ty = tx * pt.b + ty * pt.d + pt.ty;
            }
        ');

        untyped __js__('

            // multiply the alphas..
            this.worldAlpha = this.alpha * this.parent.worldAlpha;

            // reset the bounds each time this is called!
            this._currentBounds = null;
        ');

        untyped __js__('
            for (var i = 0, j = this.children.length; i < j; ++i)
            {
                this.children[i].updateTransform();
            }   
        ');

    }
}