import EmberObject from "@ember/object";
import I18n from "I18n";

const Web3Utils = EmberObject.extend({
    get limits () {
        return [
            { setting: "max_tips_per_day", momentType: "day" },
            { setting: "max_tips_per_hour", momentType: "hour" },
            { setting: "max_tips_per_minute", momentType: "minute" }
        ].map(v => ({ 
            ...v, 
            hasTips: 0
        }));
    },

    intermediateValues(min, max, count) {
        if (count < 2) {
          throw new Error('The count of intermediate values should be at least 2.');
        }
      
        // Calculate the step size
        const step = (max - min) / (count - 1);
      
        // Determine the maximum number of decimal places
        let maxDecimalPlaces = Math.max(Number(min).countDecimals(), Number(max).countDecimals());
      
        // Generate the intermediate values
        const values = [];
      
        for (let i = 0; i < count; i++) {
          const value = min + (step * i);
          if (maxDecimalPlaces === 0 && Number(value).countDecimals() > 0) {
            maxDecimalPlaces = 2; // Consider 2 decimal places if unrounded value has decimals
          }
      
          const roundedValue = Number(value.toFixed(maxDecimalPlaces));
          values.push(roundedValue);
        }
        
        return values;
    },

    durationConverter (type, duration) {
        switch(type) {
            case "year":
                duration = duration.asYears();
                break;
            case "month":
                duration = duration.asMonths();
                break;
            case "week":
                duration = duration.asWeeks();
                break;
            case "day":
                duration = duration.asDays();
                break;
            case "hour":
                duration = duration.asHours();
                break;
            case "minute":
                duration = duration.asMinutes();
                break;
            case "seconds":
                duration = duration.asSeconds();
                break;
        }

        return duration;
    }
});

export default Web3Utils;
