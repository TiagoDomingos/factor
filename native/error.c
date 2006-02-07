#include "factor.h"

void init_errors(void)
{
	thrown_error = F;
}

void fatal_error(char* msg, CELL tagged)
{
	fprintf(stderr,"Fatal error: %s %ld\n",msg,tagged);
	exit(1);
}

void critical_error(char* msg, CELL tagged)
{
	fprintf(stderr,"Critical error: %s %ld\n",msg,tagged);
	factorbug();
}

void early_error(CELL error)
{
	if(userenv[BREAK_ENV] == F)
	{
		/* Crash at startup */
		fprintf(stderr,"Error during startup: ");
		print_obj(error);
		fprintf(stderr,"\n");
		factorbug();
	}
}

void throw_error(CELL error, bool keep_stacks)
{
	early_error(error);

	throwing = true;
	thrown_error = error;
	thrown_keep_stacks = keep_stacks;
	thrown_ds = ds;
	thrown_cs = cs;
	thrown_callframe = callframe;
	thrown_executing = executing;

	/* Return to run() method */
	LONGJMP(toplevel,1);
}

void primitive_throw(void)
{
	throw_error(dpop(),true);
}

void primitive_die(void)
{
	factorbug();
}

void general_error(CELL error, CELL tagged)
{
	CELL thrown = cons(userenv[ERROR_ENV],cons(error,cons(tagged,F)));
	throw_error(thrown,true);
}

/* It is not safe to access 'ds' from a signal handler, so we just not
touch it */
void signal_error(int signal)
{
	throw_error(cons(userenv[ERROR_ENV],
		cons(ERROR_SIGNAL,
			cons(tag_fixnum(signal),F))),false);
}

/* called from signal.c when a sigv tells us that we under/overflowed a page.
 * The first bool is true if it was the return stack (otherwise it's the data
 * stack) and the second bool is true if we overflowed it (otherwise we
 * underflowed it) */
void signal_stack_error(bool is_return_stack, bool is_overflow)
{
	CELL errors[] = { ERROR_STACK_UNDERFLOW, ERROR_STACK_OVERFLOW,
			  ERROR_RETSTACK_UNDERFLOW, ERROR_RETSTACK_OVERFLOW };
	const CELL error = errors[is_return_stack * 2 + is_overflow];
	throw_error(cons(userenv[ERROR_ENV], cons(error, F)), false);
}

void type_error(CELL type, CELL tagged)
{
	CELL c = cons(tag_fixnum(type),cons(tagged,F));
	general_error(ERROR_TYPE,c);
}
