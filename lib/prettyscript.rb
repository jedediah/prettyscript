require 'ripper2ruby'

module Ruby
  def self.enum_nodes sup=nil
    a = constants.sort.map{|x| const_get x }.select{|x| x.is_a? ::Class }
    a = a.select{|x| x.superclass == sup } if sup
    a
  end
  def self.print_hiearchy node=Node
    ["#{node.base_name.ljust 20} #{node.local_instance_methods}\n",
     *enum_nodes(node).map{|x| print_hiearchy x }.flatten.map{|x| "  #{x}"}]
  end

  SEXP_MAP = {
    Node                 => [:nodes],
    Assignment           => [:operator,:left,:right],
    Assoc                => [:key,:value,:operator],
    Call                 => [:target,:separator,:identifier,:arguments,:block],
    Arg                  => [:arg],
    Const                => [:namespace,:identifier],
    DelimitedVariable    => [:identifier,:value],
    Module               => [:const,:body],
    NamedAggregate       => [:identifier],
    Case                 => [:expression,:block],
    Class                => [:identifier,:operator,:super_class,:body],
    Method               => [:target,:separator,:identifier,:params,:block],
    Binary               => [:operator,:left,:right],
    IfOp                 => [:condition,:left,:right],
    Unary                => [:operator,:operand],
    Param                => [:param],
    Symbol               => [:identifier],
    #List                 [:elements],
    #DelimitedList        [:ldelim, :ldelim=, :rdelim, :rdelim=, :nodes],
    #ArgsList             [:<<],
    #Array                [:value],
    #Hash                 [:value],
    MultiAssignment      => [:kind,:splat,:elements],
    #Params               [:<<],
    #RescueParams         [],
    #Statements           [],
    Block                => [:params,:elements],
    NamedBlock           => [:identifier,:elements],
    ChainedBlock         => [:identifier,:elements,:blocks],
    If                   => [:expression,:elements,:else_block],
    #Unless               [],
    When                 => [:expression,:elements,:blocks],
    #Else                 [],
    For                  => [:variable,:operator,:range,:elements],
    IfMod                => [:expression,:elements],
    #RescueMod            [],
    #UnlessMod            [],
    While                => [:expression,:elements],
    #Until                [],
    WhileMod             => [:expression,:elements],
    #UntilMod             [],
    Program              => [:filename,:end_data,:elements],
    String               => [:elements],
    #DynaSymbol           [:elements],
    #ExecutableString     [],
    #Heredoc              [],
    Regexp               => [:elements,:rdelim],
    #Prolog               [:elements],
    #StringConcat         [:elements],
    Range                => [:operator,:left,:right],
    Token                => [:token],
    #Char                 [:value],
    #False                [:value],
    #Float                [:value],
    #HeredocBegin         [:heredoc, :heredoc=],
    #Identifier           [],
    #Integer              [:value],
    Keyword              => [:token],
    #Label                [:value],
    #Nil                  [:value],
    #StringContent        [:value],
    #True                 [:value],
    #Variable             [],
    #Whitespace           [:empty?, :inspect],
  }

  SEXP_MAP.each do |node,fields|
    node.class_exec do
      define_method :to_sexp do
        a = [node.base_name.intern]
        fields.each do |f|
          v = send f
          if f == :elements
            a << v.map{|x| x.to_sexp}
          elsif v.respond_to? :to_sexp
            a << v.to_sexp
          else
            a << v
          end
        end
        a
      end
    end
  end
  
  class Node
    def node_name
      self.class.base_name.intern
    end
    def to_sexp
      [node_name,*nodes.map{|x| x.to_sexp }]
    end
    module Composite
      class Array
        def to_sexp
          map{|x| x.to_sexp}
        end
      end
    end
  end
  class Token
    def to_sexp
      [node_name,token]
    end
  end
  class Alias
    def to_sexp
      [node_name,arguments[0].to_sexp,arguments[1].to_sexp]
    end
  end
  class List
    def elements_to_sexp
      elements.map{|n| n.to_sexp}
    end
    def to_sexp
      [node_name,elements_to_sexp]
    end
  end
end

module PrettyScript
  module Ruby
    ParseState = Class.new Struct.new(:filename, :lineno)
    
    module Nodes
      module Value
        def to_js_tail opts={}
          "#{prepend_lines opts}return #{to_js_value opts};"
        end
        def to_js_statement opts={}
          "#{to_js_prepend_lines opts};"
        end
        def to_js_value opts={}
         to_js_node opts
        end
      end
      module Statement
        def to_js_tail opts={}
          to_js_statement opts.merge(:tail=>true)
        end
        def to_js_statement opts={}
          to_js_prepend_lines opts
        end
        def to_js_value opts={}
          raise "can't take the value of a statement"
        end
      end
      module Isolate
        def to_js_parens opts={}
          "(#{to_js_node opts})"
        end
      end
      module Node
        def to_js indent=0, lineno=0, file=''
          to_js_node indent: indent, state: ParseState.new(file,lineno)
        end
        def to_js_node opts={}
          raise "node type #{self.class.base_name} not implemented"
        end
        def to_js_statement opts={}
          raise "node type #{self.class.base_name} is not a statement"
        end
        def to_js_value opts={}
          raise "node type #{self.class.base_name} does not have a value"
        end
        def to_js_parens opts={}
          to_js_value opts
        end

        def legal_js_identifier? id
          id =~ /^[a-zA-Z_$][a-zA-Z0-9_$]*$/
        end

        def string_list_to_js elements, opts={}
          if elements.empty?
            '""'
          elsif elements.size == 1
            elements[0].to_js_node opts
          else
            "[#{elements.map{|e| e.to_js_value opts}.join(',')}].join('')"
          end
        end

        def prepend_lines opts={}
          d = [position[0] - opts[:state].lineno, 0].max
          opts[:state].lineno = position[0]
          "#{"\n"*d}#{'  '*opts[:indent]}" if d > 0
        end

        def to_js_prepend_lines opts={}
          "#{prepend_lines opts}#{to_js_node opts}"
        end

        def statement_list_to_js list, opts={}
          opts = opts.dup
          curlies = opts.delete :curlies
          tail = opts.delete :tail
          opts[:indent] += 1 unless opts.delete :noindent
          s = ''

          unless list.empty?
            list[0..-2].each do |x|
              s << x.to_js_statement(opts)
            end

            if tail
              s << list.last.to_js_tail(opts)
            else
              s << list.last.to_js_statement(opts)
            end
          end

          case curlies
          when :always
            if list.empty?
              '{}'
            else
              "{#{s}}"
            end
          when :never
            if list.empty?
              ''
            else
              s
            end
          else
            if list.empty?
              ';'
            elsif list.size == 1
              s
            else
              "{#{s}}"
            end
          end
        end

        def make_js_reference base, id, opts={}
          if id.is_a?(Identifier) || id.is_a?(Variable)
            if legal_js_identifier?(id.token)
              id = id.to_js_node opts
              dot = true
            else
              id = id.token.inspect
              dot = false
            end
          elsif id.is_a? Const
            id = id.to_js_node opts
            dot = true
          else
            id = id.to_js_value opts
            dot = false
          end

          if dot
            if base
              "#{base.to_js_value opts}.#{id}"
            else
              id
            end
          else
            if base
              "#{base.to_js_value opts}[#{id}]"
            else
              raise "properties that are not valid JavaScript identifiers must be accessed with an explicit base object"
            end
          end
        end

        def make_js_call base, id, args, block, opts={}
          args = args ? args.dup : ArgsList.new
          args << block if block
          if base.nil? && (id.is_a?(Identifier) || id.is_a?(Variable)) && id.token == "return"
            if args.empty?
              "return"
            elsif args.size == 1
              "return #{args[0].to_js_node opts}"
            else
              raise "you can only return one value"
            end
          else
            "#{make_js_reference base, id, opts}(#{args.to_js_node opts})"
          end
        end

        def make_js_function id, params, statements, opts={}
          params = params ? params.to_js_node(opts) : ''
          statements = statement_list_to_js (statements || []), opts.merge(tail: true, curlies: :always)
          if id
            "function #{id.to_js_node opts}(#{params}) #{statements}"
          else
            "function(#{params}) #{statements}"
          end
        end
      end

      # misc tokens
      #module Whitespace; end
      #module Prolog; end

      # terminals
      module Identifier
        def to_js_node opts={}
          raise "instance/class variables not supported" if token =~ /^@/
          token
        end
      end

      module Keyword
        include Value
        # catch keywords that slip through like __FILE__
        def to_js_node opts={}
          token.token
        end
      end

      # references
      module Variable
        include Value
        def to_js_node opts={}
          raise "instance/class variables not supported" if token =~ /^@/
          token
        end
        def to_js_tail opts={}
          if token == "return"
            to_js_node opts
          else
            super
          end
        end
      end
      module Const
        include Value
        def to_js_node opts={}
          make_js_reference namespace, identifier, opts
        end
      end

      # special vars
      module Nil
        include Value
        def to_js_node opts={}
          'nil' # no point in translating nil -> null, can just use 'null'
        end
      end
      module True
        include Value
        def to_js_node opts={}
          'true'
        end
      end
      module False
        include Value
        def to_js_node opts={}
          'false'
        end
      end

      # simple literals
      module Integer
        include Value
        def to_js_node opts={}
          value.to_s
        end
      end
      module Float
        include Value
        def to_js_node opts={}
          value.to_s
        end
      end
      module Char
        include Value
        def to_js_node opts={}
          value.inspect
        end
      end
      module Symbol
        include Value
        def to_js_node opts={}
          value.to_s.inspect
        end
      end

      # compound literals
      module Array
        include Value
        def to_js_node opts={}
          "[#{elements.map{|e| e.to_js_node opts}.join(',')}]"
        end
      end

      module Hash
        include Value
        def to_js_node opts={}
          "{#{elements.map{|e| e.to_js_node opts}.join(',')}}"
        end
      end
      module Label
        def to_js_node opts={}
          token
        end
      end
      module Assoc
        def to_js_node opts={}
          if key.is_a?(Label)
            "#{key.token.sub(/\s*:\s*$/,'').inspect}:#{value.to_js_node opts}"
          elsif key.is_a?(String) || key.is_a?(Symbol)
            "#{key.to_js_node opts}:#{value.to_js_node opts}"
          else
            raise "only strings, symbols, and labels allowed as keys in object literals"
          end
        end
      end

      #module Range; end

      # strings
      module String
        include Value
        def to_js_node opts={}
          string_list_to_js elements, opts
        end
      end
      module DelimitedVariable
        def to_js_node opts={}
          identifier.to_js_node opts
        end
      end
      module StringConcat
        def to_js_node opts={}
          "[#{elements.map{|e| e.to_js_node opts }.join(',')}].join('')"
        end
      end
      module StringContent
        def to_js_node opts={}
          token.inspect
        end
      end

      #module HeredocBegin; end  TODO: ripper2ruby handles heredocs badly, try and fix it
      #module Heredoc; end

      # string-like
      module Regexp
        include Value
        def to_js_node opts={}
          "(new RegExp(#{string_list_to_js elements, opts},\"#{rdelim.token.sub /^\//,''}\"))"
        end
      end
      module DynaSymbol
        include Value
        def to_js_node opts={}
          string_list_to_js elements, opts
        end
      end
      #module ExecutableString; end    # backticks

      # lists
      module ArgsList
        def to_js_node opts={}
          elements.map{|x| x.to_js_node opts }.join(',')
        end
      end
      module Arg
        def to_js_node opts={}
          raise "splats and block args not supported" if ldelim
          arg.to_js_value opts
        end
      end

      module Params
        def to_js_node opts={}
          elements.map{|x| x.to_js_node opts }.join(',')
        end
      end
      module Param
        def to_js_node opts={}
          raise "default parameter values and block parameters not supported" unless param.is_a? Identifier
          raise "splat parameters not supported" if ldelim
          param.to_js_node opts
        end
      end

      # operators
      module Unary
        include Value
        include Isolate
        def to_js_node opts={}
          "#{operator.token}#{operand.to_js_parens opts}"
        end
      end
      module Binary
        include Value
        include Isolate
        def to_js_node opts={}
          "#{left.to_js_parens opts}#{operator.token}#{right.to_js_parens opts}"
        end
      end

      module Assignment
        include Value
        include Isolate
        def to_js_node opts={}
          "#{left.to_js_node opts}#{operator.token}#{right.to_js_parens opts}"
        end
      end
      #module MultiAssignment; end
      module IfOp
        include Value
        include Isolate
        def to_js_node opts={}
          "#{condition.to_js_parens opts} ? "\
          "#{left.to_js_parens opts} : "\
          "#{right.to_js_parens opts}"
        end
      end

      # conditionals
      module If
        include Statement
        def to_js_node opts={}
          s = "if (#{expression.to_js_value opts}) #{elements[0].to_js_statement opts}"
          s << " #{blocks[0].to_js_node opts}" if blocks[0]
          s
        end
      end
      module Unless
        include Statement
        def to_js_node opts={}
          s = "if (!(#{expression.to_js_value opts})) #{elements[0].to_js_statement opts}"
          s << " #{blocks[0].to_js_node opts}" if blocks[0]
          s
        end
      end
      module Else
        def to_js_node opts={}
          s = prepend_lines opts
          if opts[:switch]
            "#{s}default: #{elements[0].to_js_node opts.merge(curlies: :never, switch: false)} break;"
          else
            "#{s}else #{elements[0].to_js_statement opts}"
          end
        end
      end
      module IfMod
        include Statement
        def to_js_node opts={}
          "if (#{expression.to_js_value opts}) #{elements[0].to_js_statement opts};"
        end
      end
      module UnlessMod
        include Statement
        def to_js_node opts={}
          "if (!(#{expression.to_js_value opts})) #{elements[0].to_js_statement opts};"
        end
      end
      module Case
        include Statement
        def to_js_node opts={}
          "switch (#{expression.to_js_value opts}) {#{block.to_js_node opts}}"
        end
      end
      module When
        def to_js_node opts={}
          s = prepend_lines opts
          expression.elements.each do |x|
            s << "case #{x.arg.to_js_value opts}: "
          end
          s << "#{elements[0].to_js_node opts.merge(curlies: :never)} break;"
          s << " #{blocks[0].to_js_node opts.merge(switch:true)}" if blocks[0]
          s
        end
      end

      # loops
      module While
        include Statement
        def to_js_node opts={}
          "while (#{expression.to_js_value opts}) #{elements[0].to_js_statement opts.merge(tail:false)}"
        end
      end
      module WhileMod
        include Statement
        def to_js_node opts={}
          "while (#{expression.to_js_value opts}) #{elements[0].to_js_statement opts.merge(tail:false)}"
        end
      end
      module Until
        include Statement
        def to_js_node opts={}
          "while (!(#{expression.to_js_value opts})) #{elements[0].to_js_statement opts.merge(tail:false)}"
        end
      end
      module UntilMod
        include Statement
        def to_js_node opts={}
          "while (!(#{expression.to_js_value opts})) #{elements[0].to_js_statement opts.merge(tail:false)}"
        end
      end
      module For
        include Statement
        def to_js_node opts={}
          raise "left side of for/in must be a single variable name" unless variable.is_a? Identifier
          "for (var #{variable.to_js_node opts} in #{range.to_js_value opts}) #{elements[0].to_js_statement opts.merge(tail:false)}"
        end
      end

      # exception handling
      module RescueMod; end
      module NamedBlock
        def to_js_node opts={}
          case identifier
          when "ensure"
            "finally #{statement_list_to_js elements, opts.merge(curlies: :always)}"
          else
            raise "unhandled NamedBlock type '#{identifier}'"
          end
        end
      end
      module ChainedBlock
        include Statement
        def to_js_node opts={}
          case identifier.token
          when "begin"
            katch = finally = nil
            blocks.each do |b|
              case b.identifier.token
              when "else"
                raise "else blocks not allowed in rescue"
              when "rescue"
                katch = b
              when "ensure"
                finally = b
              else
                raise "unhandled ChainedBlock type '#{b.identifier}'"
              end
            end
            if katch || finally
              s = "try #{statement_list_to_js elements, opts.merge(curlies: :always)}"
              s << " #{katch.to_js_node opts}" if katch
              s << " #{finally.to_js_node opts}" if finally
              s
            else
              statement_list_to_js elements, opts
            end
          when "rescue"
            raise "rescue must have exactly one parameter with no exception type" unless params.size == 1
            "#{prepend_lines opts}catch(#{params.to_js_node opts}) #{statement_list_to_js elements, opts.merge(curlies: :always)}"
          when "ensure"
            # TODO ???
          else
            if parent.is_a? Method
              # 'def' body
              statement_list_to_js elements, opts.merge(:curlies => true)
            else
              raise "unhandled ChainedBlock type '#{identifier}'"
            end
          end
        end
        def to_js_tail opts={}
          to_js_node opts.merge(tail:true)
        end
        def to_statement opts={}
          raise "ChainedBlock type #{identifier} is not a statement" unless identifier.token == "begin"
          to_js_prepend_lines opts
        end
      end
      module RescueParams
        def to_js_node opts={}
          raise "rescue must have exactly one parameter with no exception type" unless
            elements.size == 1 && elements[0].param.is_a?(Assoc) &&
            elements[0].param.key.nil? && elements[0].param.value.is_a?(Identifier)
          elements[0].param.value.to_js_node opts
        end
      end

      # method calls
      module Call
        include Value
        # target, separator, identifier, arguments, block
        # 'foo'          => Variable("foo")
        # 'foo'          => Call :identifier => Identifier("foo"), :arguments => nil
        # 'foo()'        => Call :identifier => Identifier("foo"), :arguments => ArgsList[]
        # 'Foo'          => Const :identifier => Identifier("Foo")
        # 'Foo 1'        => Call :identifier => Const(:identifier => Identifier("Foo")), :arguments => :ArgsList[Arg(Integer(1))]
        # 'Foo()'        => Call :identifier => Const(:identifier => Identifier("Foo")), :arguments => :ArgsList[]
        # 'Foo::Bar'     => Const :namespace => Const(:identifier => Identifier("Foo")), :identifier => Identifier("Bar")
        def to_js_node opts={}
          if arguments && arguments.ldelim && arguments.ldelim.token == "["
            # call to []
            raise "property access [] must have exactly one argument" unless arguments.size == 1
            raise "property access can't have block" if block
            make_js_reference target, arguments[0], opts
          elsif arguments || block
            # call either has 1+ args or 0+ args with parens or block
            make_js_call target, identifier, arguments, block, opts
          else
            # call has no arguments, parens or block.. treat it as a reference in JS
            make_js_reference target, identifier, opts
          end
        end

        def to_js_tail opts={}
          if target.nil? && identifier.to_js_node(opts) == "return"
            to_js_node opts
          else
            super
          end
        end
      end

      # blocks
      module Block
        include Value
        def to_js_node opts={}
          make_js_function nil, params, elements, opts
        end
      end

      # statements
      module Statements
        include Statement
        def to_js_node opts={}
          statement_list_to_js elements, opts
        end
        def to_js_statement opts={}
          # don't prepend lines
          to_js_node opts
        end
      end

      module Method
        include Statement
        # target, separator, identifier, params, block
        def to_js_node opts={}
          if target
            # singleton def
            "#{make_js_reference target, identifier, opts} = #{make_js_function nil, params, block}"
          else
            # instance method def
            make_js_function identifier, params, block, opts
          end
        end
        def to_js_value opts={}
          to_js_node opts
        end
      end
      #module Module; end
      #module Class; end
      #module Alias; end
      module Program
        def to_js_node opts={}
          statement_list_to_js elements, opts.merge(noindent: true, curlies: :never)
        end
      end
    end # Nodes

    Nodes.constants.each do |c|
      ::Ruby.const_get(c).send :include, Nodes.const_get(c) if ::Ruby.const_defined? c
    end
  end # Ruby
end # PrettyScript
