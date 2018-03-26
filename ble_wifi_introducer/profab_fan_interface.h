/*Profab value notes
 *
 * Fan values
 *
 * Fan Level: 7 discrete fan levels 0x00-0x06
 *
 * Fan power: boolean on or off -> 0x00 for off and 0x01 for on
 *
 * Fan direction: 0x00 for forward direction, 0x01 for reverse direction
 *
 * */
#define FAN_ON  0x01
#define FAN_OFF 0x00

#define FORWARD_DIRECTION   0x00
#define REVERSE_DIRECTION   0x01

#define FAN_LEVEL_ONE       0x00
#define FAN_LEVEL_TWO       0x01
#define FAN_LEVEL_THREE     0x02
#define FAN_LEVEL_FOUR      0x03
#define FAN_LEVEL_FIVE      0x04
#define FAN_LEVEL_SIX       0x05
#define FAN_LEVEL_SEVEN     0x06

/*
 *  Set the fan level to value in range {0x00, 0x06}
 */
wiced_result_t skuplug_set_fan_level(uint8_t fan_level);

/*
 *  Set fan power to either on 0x01 or off 0x00
 */
wiced_result_t skuplug_set_fan_power(uint8_t fan_power);

/*
 *  Set the fan direction to either forward 0x00 or reverse 0x01
 */
wiced_result_t skuplug_set_fan_direction(uint8_t fan_direction);
