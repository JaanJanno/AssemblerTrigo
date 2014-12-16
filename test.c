#include "lib.h"
#include <stdio.h>

int main(int argc, char** argv, char** envp)
{
	int i;
	float arg, sin1, sin2;

	for (i = 0 ; i < 30 ; i++) {
		arg = (i - 15) * 0.586764;
		sin1 = siinus(arg);
		printf("sin(%f) = %f (keerulisem)\n", arg, sin1);
		sin2 = siinusLihtsamalt(arg);
		printf("sin(%f) = %f (lihtsam)\n\n", arg, sin2);
	}

	return 0;
}