package pl.deluxe.utils
{
    public class MathUtil
    {
        /**
         * Calculates if occurance may happen with given chance.
         * 
         * @param chance Percentage chance from 0 to 100.
         * @throws RangeError if chance will be out of range.
         * @return true if occured; otherwise false.
         */ 
        public static function getPropability(chance : Number) : Boolean
        {
            if(chance < 0 || chance > 100)
                throw new RangeError("Chance out of range! Must be between 0 and 100.");
            
            return Math.random() * 100 <= chance;
        }
        
        /**
         * Check if point is inside triangle.
         * 
         * @param pointX Point x.
         * @param pointY Point y.
         * @param ax First triangle vertex x.
         * @param ay First triangle vertex y.
         * @param bx Second triangle vertex x.
         * @param by Second triangle vertex y.
         * @param cx Third triangle vertex x.
         * @param cy Third triangle vertex y.
         * 
         * @return <code>true</code> if point is inside triangle; otherwise <code>false</code>. 
         */ 
        public static function pointIntersectsTriangle(pointX : Number, 
                                                       pointY : Number, 
                                                       ax     : Number, 
                                                       ay     : Number, 
                                                       bx     : Number, 
                                                       by     : Number, 
                                                       cx     : Number, 
                                                       cy     : Number) : Boolean
        {
            var a : int = pointAgainstLine(pointX, pointY, ax, ay, bx, by);
            var b : int = pointAgainstLine(pointX, pointY, bx, by, cx, cy);
            var c : int = pointAgainstLine(pointX, pointY, cx, cy, ax, ay);
            
            if(a > 0 && b > 0 && c > 0)
                return true;
            
            if(a == 0 && b > 0 && c > 0)
                return true;
            
            if(a > 0 && b == 0 && c > 0)
                return true;
            
            if(a > 0 && b > 0 && c == 0)
                return true;
            
            if(a != 0 && b != 0 && c != 0 && (a < 0 || b < 0 || c < 0))
                return false;
            
            return false;
        }
        
        /**
         * Checks on which side of the give line (described by two points on this line) the point is. 
         * This method actualy computes the angle between two vectors ([Point, A] and [A, B]).
         * 
         * @param pointX Point x.
         * @param pointY Point y.
         * @param ax First point on line x.
         * @param ay First point on line y.
         * @param bx Second point on line x.
         * @param by Second point on line y.
         * 
         * @return Negative number if point is on the left side of line, positive if on right and zero if point is on line.
         */ 
        public static function pointAgainstLine(pointX : Number, 
                                                pointY : Number, 
                                                ax     : Number, 
                                                ay     : Number, 
                                                bx     : Number, 
                                                by     : Number) : Number
        {
            return ax * by + bx * pointY + pointX * ay - pointX * by - ax * pointY - bx * ay;
        }
        
        public static function circleIntersectsRect(circleCenterX : Number, 
                                                    circleCenterY : Number, 
                                                    radius        : Number,
                                                    rectCenterX   : Number, 
                                                    rectCenterY   : Number, 
                                                    rectWidth     : Number, 
                                                    rectHeight    : Number) : Boolean
        {
            var cx : Number = Math.abs(circleCenterX - rectCenterX);
            var cy : Number = Math.abs(circleCenterY - rectCenterY);
            
            if (cx > (rectWidth/2 + radius)) return false;
            if (cy > (rectHeight/2 + radius)) return false;
            
            if (cx <= (rectWidth/2)) return true;
            if (cy <= (rectHeight/2)) return true;
            
            var cornerDistance_sq : Number = Math.pow(cx - rectWidth/2, 2) +
                                             Math.pow(cy - rectHeight/2, 2);
            
            return (cornerDistance_sq <= Math.pow(radius, 2));
        }
        
        public static function distance(ax : Number, ay : Number, bx : Number, by : Number) : Number
        {
            return Math.abs(Math.sqrt((Math.pow(bx - ax, 2)) + (Math.pow(by - ay, 2))));
        }
    }
}