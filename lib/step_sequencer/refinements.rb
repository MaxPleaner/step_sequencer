module StepSequencer::Refinements

  # =============================================================================
  # String#strip_heredoc
  # -----------------------------------------------------------------------------
  # Another one from active support, this lets heredocs be indented without
  # effecting the underlying string
  # =============================================================================
  module StringStripHeredoc
    def strip_heredoc
      indent = scan(/^[ \t]*(?=\S)/).min.__send__(:size) || 0
      gsub(/^[ \t]{#{indent}}/, '')
    end
    refine String do
      include StepSequencer::Refinements::StringStripHeredoc
    end
  end


  # =============================================================================
  # String#blank
  # -----------------------------------------------------------------------------
  # ActiveSupport provides a similar method for many classes,
  # but from my experience the most useful is the String patch
  # =============================================================================
  module StringBlank
    def blank?
      /\A[[:space:]]*\z/ === self
    end
    refine String do
      include StepSequencer::Refinements::StringBlank
    end
  end

  # Object#yield_self
  # -----------------------------------------------------------------------------
  # is in Ruby since a v2.5 patch although there it's implemented on Kernel,
  # which, being a module, makes it difficult to refine.
  # Anyway, this is a backport; and it's a incredibly simply function
  # =============================================================================
  module ObjectYieldSelf
    def yield_self(&blk)
      blk&.call self
    end
    refine Object do
      include StepSequencer::Refinements::ObjectYieldSelf
    end
  end

  # =============================================================================
  # String#rational_eval
  # -----------------------------------------------------------------------------
  # a method I've written to help work with rational numbers.
  # It evals a string containing math, but wraps all number values in a call
  # It raises an error if the result is not a rational
  # =============================================================================
  module StringRationalEval
    def rational_eval
      result = eval <<-RB
        Rational(#{
          gsub(/\d[\d\.\_]*/) { |str| "Rational(#{str})"}
        })
      RB
      result.is_a?(Rational) ? result : raise("#{result} is not Rational")
    end
    refine String do
      include StepSequencer::Refinements::StringRationalEval
    end
  end
  
  # =============================================================================
  # Symbol#call
  # -----------------------------------------------------------------------------
  # cryptic but immensely useful.
  # It enables passing arguments with the symbol-to-proc shorthand, e.g.:
  #   [1,2,3].map(&:+.(1)) == [2,3,4]
  # source: https://stackoverflow.com/a/23711606/2981429
  # =============================================================================
  module SymbolCall
    def call(*args, &block)
      ->(caller, *rest) { caller.send(self, *rest, *args, &block) }
    end
    refine Symbol do
      include StepSequencer::Refinements::SymbolCall
    end
  end

  # =============================================================================
  # String#constantize
  # -----------------------------------------------------------------------------
  # comes from activesupport
  # =============================================================================
  module StringConstantize
    def constantize
      names = self.split("::".freeze)
      # Trigger a built-in NameError exception including the ill-formed constant in the message.
      Object.const_get(self) if names.empty?
      # Remove the first blank element in case of '::ClassName' notation.
      names.shift if names.size > 1 && names.first.empty?
      names.inject(Object) do |constant, name|
        if constant == Object
          constant.const_get(name)
        else
          candidate = constant.const_get(name)
          next candidate if constant.const_defined?(name, false)
          next candidate unless Object.const_defined?(name)
          # Go down the ancestors to check if it is owned directly. The check
          # stops when we reach Object or the end of ancestors tree.
          constant = constant.ancestors.inject(constant) do |const, ancestor|
            break const    if ancestor == Object
            break ancestor if ancestor.const_defined?(name, false)
            const
          end
          # owner is in Object, so raise
          constant.const_get(name, false)
        end
      end
    end
    refine String do
      include StepSequencer::Refinements::StringConstantize
    end

  end
end