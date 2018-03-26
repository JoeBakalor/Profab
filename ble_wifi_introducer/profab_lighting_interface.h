


/*Profab value notes
 *
 * Lighting Values
 *
 * Light level: 0-100% -> 0x00-0xFF where zero is the minimum dim level
 *
 * Light power: boolean on or off -> 0x00 for off and 0x01 for on
 *
 * Minimum Dim level: 7 discrete dim levels 0x00-0x06
 *
 * */

#define LIGHT_ON  0x01
#define LIGHT_OFF 0x00

#define DIM_LEVEL_ONE       0x00
#define DIM_LEVEL_TWO       0x01
#define DIM_LEVEL_THREE     0x02
#define DIM_LEVEL_FOUR      0x03
#define DIM_LEVEL_FIVE      0x04
#define DIM_LEVEL_SIX       0x05
#define DIM_LEVEL_SEVEN     0x06


/*
 *  Set the light level to value in range {0x00, 0xFF}
 */
wiced_result_t skuplug_set_light_level(uint8_t light_level);

/*
 *  Set the light power to either on 0x01 or off 0x00
 */
wiced_result_t skuplug_set_light_level(uint8_t light_power);

/*
 *  Set the light min dim level to value in range {0x00, 0x06}
 */
wiced_result_t skuplug_set_light_level(uint8_t min_dim_level);
