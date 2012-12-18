module HealthSeven
  class Treetop::Runtime::SyntaxNode
  end

  class MessageLiteral < Treetop::Runtime::SyntaxNode
  end

  class SegmentLiteral < Treetop::Runtime::SyntaxNode
    def name
      @name ||= self.text_value.split('|')[0]
    end

    def fields
      @fields ||= self.text_value.gsub(name + '|', '')
    end
  end

  class FieldsLiteral < Treetop::Runtime::SyntaxNode
  end
end
