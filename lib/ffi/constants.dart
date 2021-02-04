class JSTag {
  /* all tags with a reference count are negative */
  static const FIRST = -11; /* first negative tag */
  static const BIG_DECIMAL = -11;
  static const BIG_INT = -10;
  static const BIG_FLOAT = -9;
  static const SYMBOL = -8;
  static const STRING = -7;
  static const MODULE = -3; /* used internally */
  static const FUNCTION_BYTECODE = -2; /* used internally */
  static const OBJECT = -1;

  static const INT = 0;
  static const BOOL = 1;
  static const NULL = 2;
  static const UNDEFINED = 3;
  static const UNINITIALIZED = 4;
  static const CATCH_OFFSET = 5;
  static const EXCEPTION = 6;
  static const FLOAT64 = 7;
  /* any larger tag is FLOAT64 if JS_NAN_BOXING */
}

class JSProp {
  /* flags for object properties */
  static const CONFIGURABLE = (1 << 0);
  static const WRITABLE = (1 << 1);
  static const ENUMERABLE = (1 << 2);
  static const C_W_E = (CONFIGURABLE | WRITABLE | ENUMERABLE);
  static const LENGTH = (1 << 3); /* used internally in Arrays */
  static const TMASK = (3 << 4); /* mask for NORMAL, GETSET, VARREF, AUTOINIT */
  static const NORMAL = (0 << 4);
  static const GETSET = (1 << 4);
  static const VARREF = (2 << 4); /* used internally */
  static const AUTOINIT = (3 << 4); /* used internally */
}