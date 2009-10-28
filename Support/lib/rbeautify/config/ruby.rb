# define ruby language

unless RBeautify::Language.language(:ruby)

  ruby = RBeautify::Language.add_language(:ruby)

  pre_keyword_boundary = '(^|[^a-z0-9A-Z:._])' # like \b but with : , . _ all added to list of exceptions

  ruby.indent_size = 2

  ruby.add_matcher(:program_end, /^__END__$/, false, :format_content => false, :parse_content => false)

  ruby.add_matcher(:multiline_comment, /^=begin/, /^=end/, :format_content => false, :parse_content => false)

  ruby.add_matcher(:double_quote,
                   /"/,
                   /"/,
                   :parse_content => true,
                   :format_content => false,
                   :escape_character => true,
                   :nest_except => [:double_quote, :single_quote, :regex, :back_tick])

  # NEED TO MODIFY DOUBLE QUOTE TO BE FORMATTED to get this to work
  ruby.add_matcher(:interpolation,
                   /#\{/,
                   /\}/,
                   :nest_only => [:double_quote, :regex, :backtick])

  ruby.add_matcher(:single_quote,
                   /'/,
                   /'/,
                   :parse_content => false,
                   :format_content => false,
                   :escape_character => true,
                   :nest_except => [:double_quote, :single_quote, :regex, :back_tick])

  ruby.add_matcher(:regex,
                   /(^|((,|=|~)\s*))\//, # Try to distinguish it from division sign
                   /\//,
                   :format_content => false,
                   :escape_character => true,
                   :end_can_also_be_start => false,
                   :nest_except => [:double_quote, :single_quote, :regex, :back_tick])

  ruby.add_matcher(:back_tick,
                   /`/,
                   /`/,
                   :format_content => false,
                   :escape_character => true,
                   :nest_except => [:double_quote, :single_quote, :regex, :back_tick])

  ruby.add_matcher(:standard,
                   /((^(module|class|def))|#{pre_keyword_boundary}do)\b/,
                   /(^|;\s*)(end|rescue|ensure)\b/,
                   :nest_except => [:double_quote, :regex, :backtick])

  ruby.add_matcher(:implicit_end,
                   /^(public|protected|private)$/,
                   /^(public|protected|private)(\s*)?(#.*)?$/,
                   :end => :implicit,
                   :nest_except => [:double_quote, :regex, :backtick])

  ruby.add_matcher(:more,
                   /(=\s+|^)(until|for|while)\b/,
                   /(^|;\s*)end\b/,
                   :nest_except => [:double_quote, :regex, :backtick])

  ruby.add_matcher(:begin,
                   /((=\s+|^)begin)|(^(ensure|rescue))\b/,
                   /(^|;\s*)(end|rescue|ensure)\b/,
                   :nest_except => [:double_quote, :regex, :backtick])

  ruby.add_matcher(:if,
                   /(((^|;\s*)(if|unless))|#{pre_keyword_boundary}(then|elsif|else))\b/,
                   /#{pre_keyword_boundary}(then|elsif|else|end)\b/,
                   :nest_except => [:case, :double_quote, :regex, :backtick])

  ruby.add_matcher(:case,
                   /#{pre_keyword_boundary}case\b/,
                   /(^|;\s*)end\b/,
                   :nest_except => [:double_quote, :regex, :backtick])

  ruby.add_matcher(:inner_case,
                   /((^|;\s*)(when|else)|#{pre_keyword_boundary}then)\b/,
                   /((^|;\s*)(when|else)|#{pre_keyword_boundary}then)\b/,
                   :nest_only => [:case],
                   :end => :implicit,
                   :end_can_also_be_start => true,
                   :nest_except => [:double_quote, :regex, :backtick])

  # TODO: Improve the check that this is not a block with arguments. Will
  # currently match any bracket followed by spaces and |.
  bracket_indent_end_line_proc = Proc.new { |block| !block.after_match.empty? && !block.after_match.match(/^\|/) }
  bracket_indent_size_proc = Proc.new do |block|
    if bracket_indent_end_line_proc.call(block)
      strict_ancestors_on_same_line = block.ancestors.select { |a| a != block && a.line_number == block.line_number }
      block.end_offset - strict_ancestors_on_same_line.inject(0) { |sum, a| sum + a.indent_size }
    end
  end

  ruby.add_matcher(:curly_bracket,
                   /\{\s*/,
                   /\}/,
                   :indent_end_line => bracket_indent_end_line_proc,
                   :indent_size => bracket_indent_size_proc,
                   :nest_except => [:double_quote, :regex, :backtick])

  ruby.add_matcher(:round_bracket,
                   /\(\s*/,
                   /\)/,
                   :indent_end_line => bracket_indent_end_line_proc,
                   :indent_size => bracket_indent_size_proc,
                   :nest_except => [:double_quote, :regex, :backtick])

  ruby.add_matcher(:square_bracket,
                   /\[\s*/,
                   /\]/,
                   :indent_end_line => bracket_indent_end_line_proc,
                   :indent_size => bracket_indent_size_proc,
                   :nest_except => [:double_quote, :regex, :backtick])

  ruby.add_matcher(:comment, /(\s*)?#/,
                   /$/,
                   :parse_content => false,
                   :format_content => false,
                   :nest_except => [:double_quote, :single_quote, :regex, :back_tick])

  ruby.add_matcher(:continuing_line,
                   /(,|\.|\+|-|=\>|=|&&|\|\||\\|==|\s\?|:)(\s*)?(#.*)?$/,
                   /(^|(,|\.|\+|-|=\>|=|&&|\|\||\\|==|\s\?|:)(\s*)?)(#.*)?$/,
                   :indent_end_line => true,
                   :negate_ends_match => true,
                   :nest_except => [:continuing_line, :curly_bracket, :round_bracket, :square_bracket, :double_quote, :single_quote, :regex, :back_tick])

end
