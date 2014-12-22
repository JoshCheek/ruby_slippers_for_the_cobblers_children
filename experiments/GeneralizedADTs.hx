// Failed experiment >.<


// num list -> (Int (Int EOL))
// want: car:Int, cdr:(EOL|NumList)
// which means you can't have: EOL

enum NumList<T, U> {
  Node(x:Int, rest:NumList<T, T>):NumList<T, U>;
  EOL:NumList<T, U>;
}

enum Z {}
enum S<A>{}



class GeneralizedADTs {
  function mkNode<A, B>(a:Int, b:NumList<A, B>):NumList<S<A>, A> {
    // Node(a, b) : NumList<A>
    return Node(a, b);

    // ??Node(a, b)?? : NumList<S<A>>
  }

  // function mkEnd():NumList<Z> {
  //   return EOL;
  // }

  // function count(a:NumList<S<T>>) {
  // }

  public static function main() {
  }
}

// -----------------------------------------

/*
enum EvaluationState {
  // ...
  EvaluationList(value:EvaluationListValue);
  Class(name:??, superclass:??, body:EvaluationState);
}

enum EvaluationListValue {
  Cons(current:EvaluationState, next:EvaluationListValue);
  ListEnd;
}

EvaluationState(ListEnd) // => Evaluated(world.rubyNil)
*/


// ----------------------------------------------

/*

// RUBY:
class A
end
{type: "class", namespace:??, superclass:??, body:null}


class A
  1
end
{type: "class", namespace:??, superclass:??, body:{type:"int", value:"1"}}


class A
  1
  2
end
{type: "class",
  namespace:??,
  superclass:??,
  body:{
    type:        "expression_list",
    expressions: [{type: "int", value: "1"}
                  {type: "int", value: "2"}
                 ]

  }
}

*/
