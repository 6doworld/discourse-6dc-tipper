# frozen_string_literal: true

class TipperValueValidator
    def initialize(opts = {})
      @opts = opts
      @max_tip_value = SiteSetting.maximum_tip_validator
      @min_tip_value = SiteSetting.minimum_tip_validator
    end
    
    def is_num?(str)
      !!Integer(str)
      rescue ArgumentError, TypeError
        false
    end
    
    def is_float?(str)
      !!Float(str)
      rescue ArgumentError, TypeError
        false
    end

    def valid_value?(value)
      if is_num?(value) || is_float?(value)
        if Float(value) > @max_tip_value || Float(value) < @min_tip_value
          return false
        end
        return true
      end
      return false
    end
  
    def error_message
      "Please enter a valid value between #{Float(@min_tip_value)}-#{Float(@max_tip_value)}"
    end
end