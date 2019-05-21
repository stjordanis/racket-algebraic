#lang scribble/manual

@title[#:tag "stxlist" #:style 'quiet]{Syntax Pairs and Lists}

@require{./algebraic-includes.rkt}

@require[
  @for-label[
    algebraic/racket/base
    algebraic/syntax/list
    racket/contract/base
  ]
]

@define[syntax-list-eval (algebraic-evaluator)]
@define-syntax[example (algebraic-example syntax-list-eval)]

@example[#:hidden (require algebraic/syntax/list)]

@; #############################################################################

@defmodule[algebraic/syntax/list]

Operations on @secref["pairs" #:doc '(lib
"scribblings/reference/reference.scrbl")] embedded in syntax objects.

A @deftech{syntax pair} is a pair embedded in a @gtech{syntax object}. The
first value is accessed with the @racket[syntax-cdr] procedure. Syntax pairs
are not mutable.

A @deftech{syntax list} is a list embedded in a @gtech{syntax object}. It is
either the constant @racket[syntax-null], or it is a syntax pair whose second
value is a syntax list.

@; =============================================================================

@section[#:tag "stxlist:cons"]{Syntax Pair Constructors and Selectors}

@defproc[(syntax-pair? [x syntax?]) boolean?]{

  Returns @racket[#t] if @var[x] is a @tech{syntax pair}, @racket[#f]
  otherwise.

  Examples:
  @example[
    (syntax-pair? #'1)
    (syntax-pair? #'(1 . 2))
    (syntax-pair? #'(1 2))
    (syntax-pair? #'())
  ]
}

@defproc[(syntax-null? [x syntax?]) boolean?]{

  Returns @racket[#t] if @var[x] is the empty @tech{syntax list},
  @racket[#f] otherwise.

  Examples:
  @example[
    (syntax-null? #'1)
    (syntax-null? #'(1 2))
    (syntax-null? #'())
    (syntax-null? (syntax-cdr #'(1)))
  ]
}

@defproc[(syntax-cons [a syntax?] [b syntax?]) syntax-pair?]{

  Returns a newly allocated @tech{syntax pair} with the lexical context of
  @var[a] whose first element is @var[a] and second element is @var[d].

  Examples:
  @example[
    (syntax-cons #'1 #'2)
    (syntax-cons #'1 #'())
  ]
}

@defproc[(syntax-car [p syntax-pair?]) syntax?]{

  Returns the first element of the @tech{syntax pair} @var[p].

  Examples:
  @example[
    (syntax-car #'(1 2))
    (syntax-car (syntax-cons #'2 #'3))
  ]
}

@defproc[(syntax-cdr [p syntax-pair?]) syntax?]{

  Returns the second element of the @tech{syntax pair} @var[p].

  Examples:
  @example[
    (syntax-cdr #'(1 2))
    (syntax-cdr #'(1))
  ]
}

@defthing[syntax-null syntax-null? #:value (datum->syntax #f #'())]{

  The empty @tech{syntax list}.

  Examples:
  @example[
    syntax-null
    #'()
    (syntax-null? syntax-null)
  ]
}

@defproc[(syntax-list? [x syntax?]) boolean?]{

  Returns @racket[#t] if @var[x] is a @tech{syntax list}, or a @tech{syntax
  pair} whose second element is a @tech{syntax list}.

  Examples:
  @example[
    (syntax-list? #'(1 2))
    (syntax-list? (syntax-cons #'1 (syntax-cons #'2 #'())))
    (syntax-list? (syntax-cons #'1 #'2))
  ]
}

@defproc[(syntax-list [x syntax?] ...) syntax-list?]{

  Returns a newly allocated @tech{syntax list} containing the @var[x]s as its
  elements. If @var[x]s are given, the new syntax object has the lexical
  context of the first one.

  Examples:
  @example[
    (syntax-list #'1 #'2 #'3 #'4)
    (syntax-list (syntax-list #'1 #'2) (syntax-list #'3 #'4))
  ]
}

@defproc[(syntax-list* [x syntax?] ... [tail syntax?]) syntax?]{

  List @racket[syntax-list], but the last argument is used as the tail of the
  result, instead of the final element. The result is a @tech{syntax list}
  only if the last argument is a @tech{syntax list}.

  Examples:
  @example[
    (syntax-list* #'1 #'2)
    (syntax-list* #'1 #'2 (syntax-list #'3 #'4))
  ]
}

@defproc[
  (build-syntax-list [n exact-nonnegative-integer?]
                     [f (-> exact-nonnegative-integer? syntax?)])
  syntax-list?
]{

  Creates a @tech{syntax list} of @var[n] elements by applying @var[f] to the
  integers from @racket[0] to @racket[(sub1 #,(var n))] in order. If @var[x]
  is the resulting @tech{syntax list}, then @racket[(syntax-list-ref #,(var x)
  #,(var i))] is the value produced by @racket[(f #,(var i))].

  Examples:
  @example[
    (build-syntax-list 10 (>> datum->syntax #f))
    (build-syntax-list 5 (φ x (datum->syntax #f (* x x))))
  ]
}

@; =============================================================================

@section[#:tag "stxlist:list"]{Syntax List Operations}

@defproc[(syntax-length [x syntax-list?]) exact-nonnegative-integer?]{

  Returns the number of elements in @var[x].

  Examples:
  @example[
    (syntax-length (syntax-list #'1 #'2 #'3 #'4))
    (syntax-length #'())
  ]
}

@defproc[
  (syntax-list-ref [x syntax-pair?] [pos exact-nonnegative-integer?])
  syntax?
]{

  Returns the element of @var[x] at position @var[pos], where the @tech{syntax
  list}'s first element is position @racket[0]. If the @tech{syntax list} has
  @var[pos] or fewer elements, the @racket[exn:fail:contract] exception is
  raised.

  The @var[x] argument need not actually be a @tech{syntax list}; @var[x] must
  merely start with a chain of at least @racket[(add1 #,(var pos))]
  @tech{syntax pairs}.

  Examples:
  @example[
    (syntax-list-ref (syntax-list #'a #'b #'c) 0)
    (syntax-list-ref (syntax-list #'a #'b #'c) 1)
    (syntax-list-ref (syntax-list #'a #'b #'c) 2)
    (syntax-list-ref (syntax-cons #'1 #'2) 0)
    (eval:error (syntax-list-ref (syntax-cons #'1 #'2) 1))
  ]
}

@defproc[
  (syntax-list-tail [x syntax?] [pos exact-nonnegative-integer?])
  syntax?
]{

  Returns the @tech{syntax list} after the first @var[pos] elements of
  @var[x]. If the @tech{syntax list} has fewer than @var[pos] elements, then
  the @racket[exn:fail:contract] exception is raised.

  The @var[x] argument need not actually be a @tech{syntax list}; @var[x] must
  merely start with a chain of at least @var[pos] @tech{syntax pairs}.

  Examples:
  @example[
    (syntax-list-tail #'(1 2 3 4 5) 2)
    (syntax-list-tail (syntax-cons #'1 #'2) 1)
    (eval:error (syntax-list-tail (syntax-cons #'1 #'2) 2))
    (syntax-list-tail #'not-a-pair 0)
  ]
}

@defproc*[([(syntax-append [xs syntax-list?] ...) syntax-list?]
           [(syntax-append [xs syntax-list?] ... [x syntax?]) syntax?])]{

  When given all @tech{syntax list} arguments, the result is a @tech{syntax
  list} that contains all of the elements of the given @tech{syntax lists} in
  order. The last argument is used directly in the tail of the result.

  The last argument need not be a @tech{syntax list}, in which case the result
  is an ``improper @tech{syntax list}.''

  Examples:
  @example[
    (syntax-append (syntax-list #'1 #'2) (syntax-list #'3 #'4))
    (syntax-append (syntax-list #'1 #'2) (syntax-list #'3 #'4)
                   (syntax-list #'5 #'6) (syntax-list #'7 #'8))
  ]
}

@defproc[(syntax-reverse [xs syntax-list?]) syntax-list?]{

  Returns a @tech{syntax list} that has the same elements as @var[xs], but in
  reverse order.

  Example:
  @example[
    (syntax-reverse (syntax-list #'1 #'2 #'3 #'4))
  ]
}

@; =============================================================================

@section[#:tag "stxlist:list-iteration"]{Syntax List Iteration}

@defproc[(syntax-map [f procedure?] [xs syntax-list?] ...+) syntax-list?]{

  Applies @var[f] to the elements of the @var[xs]s from the first element to
  the last. The @var[proc] argument must accept the same number of arguments
  as the number of supplied @var[xs]s and all @var[xs]s must have the same
  number of elements. The result is a @tech{syntax list} containing each
  result of @var[f] in order.

  Examples:
  @example[
    (syntax-map (.. (>> datum->syntax #f) add1 syntax-e) #'(1 2 3 4))
  ]
}

@defproc[(syntax-foldr [f procedure?] [init syntax?] [xs syntax-list?] ...+) syntax?]{

  Like @racket[syntax-foldl], but the @tech{syntax lists} are traversed from
  right to left. Unlike @racket[syntax-foldl], @racket[syntax-foldr] processes
  the @var[xs]s in space proportional to the length of the @var[xs]s (plus the
  space for each call to @var[f]).

  Examples:
  @example[
    (syntax-foldr syntax-cons #'() #'(1 2 3 4))
    (syntax-foldr
     (λ (x ys) (syntax-cons (datum->syntax #f (add1 (syntax-e x))) ys))
     #'()
     #'(1 2 3 4))
  ]
}

@; =============================================================================

@section[#:tag "stxlist:pair-accessors"]{Syntax Pair Accessor Shorthands}

@defproc[(syntax-cddr [x (syntax/c (cons/c any/c? pair?))]) syntax?]{

  Returns @racket[(syntax-cdr (syntax-cdr #,(var x)))].

  Example:
  @example[
    (syntax-cddr #'(2 1))
  ]
}