package ruby;
import ruby.ds.objects.RBinding;
import ruby.ds.objects.RObject;

class Core {
  public static function lookupClass(bnd:RBinding):RObject {
    return bnd.self.klass;
  }
}
