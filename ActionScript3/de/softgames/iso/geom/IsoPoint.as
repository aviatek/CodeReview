package de.softgames.iso.geom
{
    import flash.geom.Point;
    
    /**
     * Isometric point implementation.
     */
    public class IsoPoint
    {
        public static const ANGLE : Number = Math.cos(-Math.PI / 6) * Math.SQRT2;
        
        public var x : Number;
        public var y : Number;
        public var z : Number;
        
        
        /**
         * Constructor.
         */
        public function IsoPoint(x : Number = 0, y : Number = 0, z : Number = 0)
        {
            this.x = x;
            this.y = y;
            this.z = z;
        }
        
        public function clone() : IsoPoint
        {
            return new IsoPoint(x, y, z);
        }
        
        /**
         * Converts x,y,z to x,y (Point) in 2D onscreen projection without modifying the original point.
         * 
         * @return Converted point.
         */
        public function toCartesian() : Point
        {
            return new Point(calculateCartesianX(x, y, z), calculateCartesianY(x, y, z));
        }
        
        public static function calculateCartesianX(x : Number, y : Number, z : Number) : Number
        {
            return x - y;
        }
        
        public static function calculateCartesianY(x : Number, y : Number, z : Number) : Number
        {
            return -z * ANGLE + (x + y) * 0.5;
        }
        
        /**
         * Converts x,y Point in 2D projection to the x,y,z Point3D in 3D projection.
         * It's not returning a new point but modifies this instance.
         * Because you can't calculate y cord in 3D space from point in 2D space the y in 3D space is treated as 0.
         * 
         * @param point Point to transform.
         * 
         * @return Converted point.
         */
        public function fromPoint(point : Point) : IsoPoint
        {
            this.x = point.y + point.x * 0.5;
            this.z = 0;
            this.y = point.y - point.x * 0.5;
            return this;
        }
        
        public function set(x : Number = 0, y : Number = 0, z : Number = 0) : void
        {
            this.x = x;
            this.y = y;
            this.z = z;
        }
        
        public function toString() : String
        {
            return "[IsoPoint x: " + this.x + ", y: " + this.y + ", z: " + this.z + "]";
        }
        
        public function get cartesianX() : Number
        {
            return calculateCartesianX(this.x, this.y, this.z);
        }
        
        public function get cartesianY() : Number
        {
            return calculateCartesianY(this.x, this.y, this.z);
        }
    }
}