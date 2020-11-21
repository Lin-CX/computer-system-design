/*
 * csd_main.c
 *
 *  Created on: Apr 29, 2020
 *      Author: LCX
 */

void printChar(unsigned num, unsigned secFlag);


int csd_main()
{
	//unsigned * temp_addr;
	unsigned * pstatus_addr;				//private status address
	unsigned h, m, s;

	pstatus_addr = (unsigned *) 0xf8f0060c;	//private timer status address
	h = 0, m = 0, s = 0;

	while (1)
	{
		while (*pstatus_addr)
		{
			if (s >= 60)					//carry second to minute
			{
				++m;
				s = 0;
			}
			if (m >= 60)					//carry minute to hour
			{
				++h;
				m = 0;
			}

			printChar(h, 1);
			printChar(m, 1);
			printChar(s, 0);

			++s;

			*pstatus_addr = 1;				// to clear sticky bit in the status register
		}
	}

	return 0;
}

void printChar(unsigned num, unsigned secFlag){
	unsigned * tera_addr;					//tera term address
	tera_addr = (unsigned *) 0xe0001030;	//写入tera term的地址

	unsigned n1, n2;
	if (num > 9)
	{
		n1 = num/10 + 48;
		n2 = num%10 + 48;
	}
	else
	{
		n1 = 48;
		n2 = num + 48;
	}

	*tera_addr = n1;
	*tera_addr = n2;
	if (secFlag)
	{
		*tera_addr = ' ';
		*tera_addr = ':';
		*tera_addr = ' ';
	}
	else
	{
		*tera_addr = 0x0D;		//carriage return
	}

	return;
}
