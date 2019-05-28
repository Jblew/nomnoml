%{

function cons(list, e){
  list.push(e)
  return list
}
function last(list){
  return list[list.length-1]
}
function Rel(from, assoc, to) {
  return {from, assoc, to}
}
function Rel(from, assoc, to) {
  return {from, assoc, to}
}
function Part(lines, nodes, rels) {
  return {lines, nodes, rels}
}
function Node(type, name, parts) {
  return {t:type, name, parts}
}

%}

%lex
%%

\s*\|\s*                              return '|'
"["                                   return '['
"]"                                   return ']'
"[<"                                  return '[<'
">"                                   return '>'
[ ]*[;\n]+[ ]*                        return 'SEP'
\<[a-zA-Z]+\>                         return 'TYPE'
\s*[<>:|o+-]+\s*                      return 'ASSOC'
((\\\[|\\\]|\\;|\\\|)|[^\[\];|\n])+   return 'TXT'
<<EOF>>                               return 'EOF'
.                                     return 'INVALID'

/lex

%start root

%% /* ------------------------------------------------- */

root
 : part EOF             { return $1 }
;

part
 : rels                 { $$ = Part([], [], $1) }
 | node                 { $$ = Part([], [$1], []) }
 | TXT                  { $$ = Part([$1], [], []) }
 | part SEP rels        { $$ = cons($1.rels, $3) && $1 }
 | part SEP node        { $$ = cons($1.nodes, $3) && $1 }
 | part SEP TXT         { $$ = cons($1.lines, $3) && $1 }
;

rels
 : rels ASSOC node      { $$ = cons($1, Rel(last($1).to, $2, $3)) }
 | node ASSOC node      { $$ = [Rel($1,$2,$3)] }
;

parts
 : part                 { $$ = [$1] }
 | parts '|' part       { $$ = cons($1, $3) }
;

node
 : '[' parts ']'        { $$ = Node('<class>', $2[0].lines[0], $2) }
 | '[' TYPE parts ']'   { $$ = Node($2, $3[0].lines[0], $3) }
;
