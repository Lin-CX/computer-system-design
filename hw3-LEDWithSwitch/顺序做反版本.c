/*
 * csd_main.c
 *
 *  Created on: Mar 21, 2020
 *      Author: LCX
 */

static void Delay(unsigned ms);

int csd_main()
{
	unsigned * temp_addr;
	unsigned * LED_addr;
	unsigned data;
	unsigned d;

	temp_addr = (unsigned *) 0x001019e0;			//************************temp的值随时要改
	LED_addr = (unsigned *) 0x41200000;

	while (1)
	{
		d = 128;
		data = *temp_addr;		//fetch the SW value

		if (data == 0)			//no switch on
		{
			*LED_addr = 255;
			Delay(10);
			*LED_addr = 0;
			Delay(10);
		}
		else					//some switch on
		{
			for (unsigned i = 1; i <= 8; ++i)
			{
				if (data >= d)
				{
					*LED_addr = d;
					data -= d;
					Delay(i);
				}
				d /= 2;
			}
		}
	}


	/*while (1)
	{
		*LED_addr = 10;
		Delay(100);					//delay 1 second

		*LED_addr = 5;				//turn off LED
		Delay(100);
	}*/


	return 0;
}

static void Delay(unsigned ms)
{
	ms *= 8500000;
	while (--ms);

}
