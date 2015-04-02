macro unless {
  rule infix { return $value:expr | $guard:expr } => {
    if (!($guard)) {
      return $value;
    }
  }
}

function foo(x) {
  return true unless x > 42;
  return false;
}
