off = true
ARGF.each do |line|
  case line
  when /PSCRIPT_PARAMS_DECL_BEGIN/
    off = false
  when /PSCRIPT_PARAMS_DECL_END/
    exit
  when /pscript/
    next if off
    var = line.scan(/\w+/).last or next
    base = var.sub(/pscript_/, '')
    puts %"\#define #{base}\t\t(parser->pscript_#{base})"
  end
end
