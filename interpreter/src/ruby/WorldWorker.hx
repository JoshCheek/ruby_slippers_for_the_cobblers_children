package ruby;

import ruby.ds.objects.RClass;

class WorldWorker {
  public static function toplevelNamespace(worker:Worldly):RClass {
    return worker.world.toplevelNamespace;
  }
}
