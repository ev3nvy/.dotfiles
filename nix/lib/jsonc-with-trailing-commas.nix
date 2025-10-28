{ lib, ... }:
let
  linesPat = "[\n]";
  lineCommentsPat = "^([[:space:]]*//.*)$";
  inlineCommentsPat = "(.*,?)[[:space:]]*//.*";
  trailingCommasPat = ",([[:space:]]*)(}|\])";

  # convert string to list of strings (one string is one line)
  splitToLines =
    str:
    let
      filterStrings = list: builtins.filter (builtins.isString) list;
    in
    filterStrings (builtins.split linesPat str);

  # works only for double slash comments
  removeSingleLineComments =
    str:
    let
      commentsRemoved = list: builtins.filter (s: builtins.match lineCommentsPat s == null) list;
    in
    commentsRemoved (splitToLines str);

  # search for comments at the end of the line
  removeInlineComments =
    list:
    let
      removeComment = el: builtins.match inlineCommentsPat el;

      commentsRemoved =
        l:
        builtins.map (
          el:
          let
            commentRemoved = removeComment el;
          in
          if commentRemoved == null then el else lib.strings.concatStrings commentRemoved
        ) l;
    in
    commentsRemoved list;

  removeTrailingComma =
    str:
    let
      # remove comma (by not including it in the capture group) if it's followed by a closing brace
      # NOTE: this assumes that comments were already removed
      matchLastComma = s: builtins.split trailingCommasPat s;

      # split keeps unmached parts as they were, but interweaves capture groups as lists (e.g.
      # `["a" ["b"] "c"]`); we convert this back to a list of strings
      concatNestedListsToList =
        list: builtins.concatLists (builtins.map (el: if builtins.isString el then [ el ] else el) list);
    in
    lib.strings.concatStrings (concatNestedListsToList (matchLastComma str));

  fromJSONCWithTrailingCommas =
    str:
    let
      noComments = removeInlineComments (removeSingleLineComments str);
      stringified = removeTrailingComma (builtins.concatStringsSep "\n" noComments);
    in
    builtins.fromJSON stringified;
in
{
  inherit fromJSONCWithTrailingCommas;
}
