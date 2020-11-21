/*
 * csd_main.c
 *
 *  Created on: 2018. 4. 30.
 *      Author: Taeweon Suh
 */

unsigned volatile char * gpio_led = (unsigned char *) 0x41200000;

int csd_main()
{
	unsigned * temp_addr;
	temp_addr = (unsigned *) 0x41210000;		// sw address

 int count;
 unsigned currentSW, previousSW;

 previousSW = *temp_addr;

 while (1) {

	for (count=0; count < 3900000; count++) ;

	*gpio_led = 0x3C;

	currentSW = *temp_addr;		// check sw input
	if (currentSW != previousSW)
		return 0;

	for (count=0; count < 3900000; count++) ;

	*gpio_led = 0xC3;

	currentSW = *temp_addr;		// check sw input
	if (currentSW != previousSW)
		return 0;

 }
	return 0;
}
