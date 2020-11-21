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
	unsigned d, t;

	temp_addr = (unsigned *) 0x00101a00;			//temp的值随时要改
	LED_addr = (unsigned *) 0x41200000;

	data = *temp_addr;		//fetch the SW value

	d = 128;
	t = 1;					//delay time

	//fetch delay time
	if (data == 0)
		t = 10;				//delay one second
	else
	{
		for (unsigned i = 0; i < 8; ++i)
		{
			if (data >= d)
				break;
			++t;
			d /= 2;
		}
	}

	//LED
	while (1)
	{
		d = 1;

		for (unsigned i = 8; i >= 1; --i)
		{
			*LED_addr = d;
			Delay(t);
			d *= 2;			//1, 2, 4, 8, ..., 128
		}
	}

	return 0;
}

static void Delay(unsigned t)
{
	t *= 8500000;
	while (--t);

}
