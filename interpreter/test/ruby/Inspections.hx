package ruby;
import ruby.ds.objects.*;

class Inspections extends ruby.support.TestCase {
  public function testSpecialConstants() {
    var world = WorldDomination.bootstrap();
    rAssertEq(world.rubyNil, world.rubyNil);
  }
}
