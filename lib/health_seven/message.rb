require 'treetop'
require "#{File.dirname(__FILE__)}/nodes.rb"

module HealthSeven
  class BadGrammarException < Exception; end

  class Message
    ##
    ## GRAMMAR PART
    ##
    class SegmentDef
      def initialize(name, &block)
        @name = name
        @segments = []
        self.instance_eval(&block) if block_given?
      end

      def dsl_off!
        @dsl_off = true
      end

      def seg_name
        return '' if @name == :message
        "'#{@name.to_s[0..2].upcase}'"
      end

      def rule_name
        @name[0..2]
      end

      def optional?
        @name[-1] == '?'
      end

      def multiple?
        @name[3] == 's'
      end

      def method_missing(name, &block)
        unless @dsl_off
          @segments<< SegmentDef.new(name, &block)
        else
          super
        end
      end

      def to_gramar(gramar)
        gramar.push <<-RULE

       rule #{self.rule_name}
         #{seg_name} payload delim #{_children_enum.join(" ")} <HealthSeven::SegmentLiteral>
       end
       RULE

       @segments.each do |s|
         s.to_gramar(gramar)
       end
       gramar
      end

      def _children_enum
        children = @segments.map do |s|
          s.dsl_off!
          res = s.rule_name
          if s.optional?
            if s.multiple?
              res<< "*"
            else
              res<< "?"
            end
          else
            res<< "+" if s.multiple?
          end
          res
        end
      end
    end

    class MessageDef < SegmentDef
      def _children_enum
        @segments.map do |s|
          s.dsl_off!
          s.rule_name
        end
      end

      def optional
        @optional ||= @segments.map do |s|
          s.rule_name if s.optional?
        end.compact
      end

      def required
        @reqired ||= @segments.map do |s|
          s.rule_name unless s.optional?
        end.compact
      end

      def to_gramar(gramar)
        gramar.push <<-RULE

       rule message
         msh segment* "\\n" <HealthSeven::SegmentLiteral>
       end

       rule segment
         #{_children_enum.join(" / ")}
       end

       rule delim
         "#{13.chr}"
       end

       rule not_delim
         [^#{13.chr}]
       end

       rule payload
         not_delim+ <HealthSeven::FieldsLiteral>
       end

       rule msh
         'MSH' payload delim  <HealthSeven::SegmentLiteral>
       end
        RULE

        @segments.each do |s|
          s.to_gramar(gramar)
        end
        gramar
      end
    end

    def self.define_message(&block)
      @message_def = MessageDef.new(:message, &block)
      self.load_grammar
    end

    def self.message_def
      @message_def
    end

    def self.treetop_grammar
      <<-RULE
      grammar  #{self.name}Grammar
      #{@message_def.to_gramar([]).join("\n")}
      end
      RULE
    end

    def self.load_grammar
      Object.const_set("#{self.name}Grammar", Module.new)
      Treetop.load_from_string(treetop_grammar)
    end
    ##
    ## END OF GRAMMAR PART
    ##


    class Segment
      attr_accessor :name
      attr_accessor :fields
      attr_accessor :children

      def initialize
        @children = []
      end

      def method_missing(method_name, *args)
        res = nil
        if method_name.length == 3
          res = @children.find { |segment| segment.name == method_name.to_s.upcase }
        else
          res = @children.select { |segment| segment.name == method_name.to_s[0..2].upcase }
        end

        return res
      end

      def [](field, subfield = nil)
        f = fields.split('|')[field - 1]
        if subfield
          f.split('^')[subfield - 1]
        else
          f
        end
      end
    end

    class Message < Segment
      def[](*args)
        nil
      end
    end

    def self.parse(data)
      parser = Object.const_get("#{self.name}GrammarParser").new
      # Pass the data over to the parser instance
      ast_tree = parser.parse(data)

      # If the AST is nil then there was an error during parsing
      # we need to report a simple error message to help the user
      if(ast_tree.nil?)
        message = ""
        parser.failure_reason =~ /^(Expected .+) after/m
        message << "#{$1.gsub("\n", '$NEWLINE')}:"
        message << data.lines.to_a[parser.failure_line - 1]
        message << "#{'~' * (parser.failure_column - 1)}^"
        raise HealthSeven::BadGrammarException, message
      end
      msg = Message.new
      @required_segments = Object.const_get("#{self.name}").message_def.required
      self.clean_tree(ast_tree, msg)
      raise "No required segment(s) found: #{@required_segments.join(', ')}" unless @required_segments.empty?

      msg
    end

    def self.clean_tree(node, segment)
      if node.is_a?(Treetop::Runtime::SyntaxNode)  &&  !node.elements
        return false
      end

      segment.name = node.name
      segment.fields = node.fields
      @required_segments.delete(node.name.downcase)

      return true unless node.elements
      node.elements.each do |e|
        if e.is_a?(HealthSeven::SegmentLiteral)
          child_segment = Segment.new
          if self.clean_tree(e, child_segment)
            segment.children << child_segment
          end
        elsif e.elements
          e.elements.each do |ee|
            child_segment = Segment.new
            if self.clean_tree(ee, child_segment)
              segment.children << child_segment
            end
          end
        end
      end
    end
  end
end
