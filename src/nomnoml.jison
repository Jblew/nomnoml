%{
var cons = (list, e) => (list.push(e), list)
var last = (list) => (list[list.length-1])
var Assoc = (labelA, style, labelB) => ({labelA, style, labelB})
var Rel = (start, assoc, end)  => {
  var t = assoc.match('^(.*?)([<:o+]*-/?-*[:o+>]*)(.*)$');
  return {assoc:t[2], start, end, startLabel:t[1].trim(), endLabel:t[3].trim()};
}
var Part = (lines, nodes, rels)  => ({lines, nodes, rels})
var Node = (type, name, parts)  => ({t:type, name, parts})
%}

%lex
%%

"|"                                   return '|'
"\\\\"                                return 'LITERAL'
"\["                                  return 'LITERAL'
"\]"                                  return 'LITERAL'
"\|"                                  return 'LITERAL'
"\;"                                  return 'LITERAL'
"\;"                                  return 'LITERAL'
"["                                   return '['
"]"                                   return ']'
[;\n]+                                return 'SEP'
\<[a-zA-Z]+\>                         return 'TYPE'
[^\[\];|\n]*[^\[\];|\n\\]             return 'TXT'
\\s*                                  return 'WS'
<<EOF>>                               return 'EOF'
.                                     return 'INVALID'
/lex

%start root

%%

root
 : part EOF             { return $1 }
;

text
 : LITERAL              { $$ = $1 }
 | TXT                  { $$ = $1 }
 | text LITERAL         { $$ = $1 + $2 }
 | text TXT             { $$ = $1 + $2 }
 ;

part
 : rels                 { $$ = $1 }
 | node                 { $$ = Part([], [$1], []) }
 | text                 { $$ = Part([$1], [], []) }
 | part SEP rels        { $$ = cons($1.rels, $3) && $1 }
 | part SEP node        { $$ = cons($1.nodes, $3) && $1 }
 | part SEP text        { $$ = cons($1.lines, $3) && $1 }
;

rels
 : rels text node        { $$ = cons($1.rels, Rel(last($1.rels).end, $2, $3.name)) && cons($1.nodes, $3) && $1 }
 | node text node        { $$ = Part([], [$1,$2], [Rel($1.name,$2,$3.name)]) }
;

parts
 : part                 { $$ = [$1] }
 | parts '|' part       { $$ = cons($1, $3) }
;

node
 : '[' parts ']'        { $$ = Node('<class>', $2[0].lines[0], $2) }
 | '[' TYPE parts ']'   { $$ = Node($2, $3[0].lines[0], $3) }
;
