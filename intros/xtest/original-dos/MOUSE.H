#ifndef _MOUSE_H_
#define _MOUSE_H_

#define MOUSE_DIVIDE    2
struct mouse_info
{
   unsigned short x,y,button;
};

void mouse_on();
void mouse_off();
void setx(int,int);
void sety(int,int);
mouse_info get_m_info();



#endif

