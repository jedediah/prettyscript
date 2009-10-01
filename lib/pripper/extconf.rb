#!ruby -s

require 'mkmf'
require 'rbconfig'

def main
  unless find_executable 'gperf'
    Loggin.message 'missing gperf; abort'
    return
  end
  unless find_executable('bison')
    unless File.exist?('pscript.c') or File.exist?("#{$srcdir}/pscript.c")
      Logging.message 'missing bison; abort'
      return
    end
  end
  $objs = %w(pscript.o)
  $cleanfiles.concat %w(pscript.y pscript.c pscript.E pscript.output y.output eventids1.c eventids2table.c lex.c defs/lex.c.src)
  $defs << '-DPSCRIPT'
  $defs << '-DPSCRIPT_DEBUG' if $debug
  create_header
  create_makefile 'pscript'
end

main
