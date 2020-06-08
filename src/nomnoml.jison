%{
  var cons = (list, e) => (list.push(e), list)
  var last = (list) => (list[list.length-1])
  var Rel = (start, assoc, end)  => {
    var t = assoc.match('^(.*?)([<:o+]*-/?-*[:o+>]*)(.*)$');
    return {assoc:t[2], start, end, startLabel:t[1].trim(), endLabel:t[3].trim()};
  }
  var Part = (lines, nodes, rels)  => ({lines, nodes, rels})
  var Node = (type, name, parts)  => ({type, name, parts})
  function withRelTo(part, assoc, node) {
    part.rels.push(Rel(last(part.rels).end, assoc, node.name));
    part.nodes.push(node);
    return part;
  }
%}

%lex
%%

"|"                            return '|'
"\\\\"                         return 'LITERAL'
"\["                           return 'LITERAL'
"\]"                           return 'LITERAL'
"\|"                           return 'LITERAL'
"\;"                           return 'LITERAL'
"\;"                           return 'LITERAL'
"["                            return '['
"]"                            return ']'
[;\n]+                         return 'SEP'
\<[a-zA-Z]+\>                  return 'TYPE'
[^\[\];|\n]*[^\[\];|\n\\]      return 'TXT'
\\s*                           return 'WS'
<<EOF>>                        return 'EOF'
.                              return 'INVALID'
/lex

%start root

%%

root
 : part EOF             { return $1 }
;

text
 : LITERAL              -> $LITERAL.substr(1)
 | TXT                  -> $TXT
 | text LITERAL         -> $text + $LITERAL.substr(1)
 | text TXT             -> $text + $TXT
;

part
 : rels                 -> $rels
 | node                 -> Part([], [$node], [])
 | text                 -> Part([$text], [], [])
 | part SEP rels        -> cons($part.rels, $rels) && $part
 | part SEP node        -> cons($part.nodes, $node) && $part
 | part SEP text        -> cons($part.lines, $text) && $part
;

rels
 : rels text node       -> withRelTo($rels, $text, $node)
 | node text node       -> Part([], [$1,$2], [Rel($1.name,$2,$3.name)])
;

parts
 : part                 -> [$part]
 | parts '|' part       -> cons($parts, $part)
;

node
 : '[' parts ']'        -> Node('<class>', $parts[0].lines[0], $parts)
 | '[' TYPE parts ']'   -> Node($TYPE, $parts[0].lines[0], $parts)
;
