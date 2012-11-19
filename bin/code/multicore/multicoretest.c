/*
 * Multi-thread tests in multi-core machine
 * possibility to run serial or parallel tests
 * Michael Paquier, 2012
 * Following command to compile:
 * gcc -lpthread multicoretest.c -o multicoretest
 */

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define NUMBER_OF_OPERATIONS	100000000

static void task(int id);
static void serial(int num_tasks);
static void* threaded_task(void *t);
static void parallel(int num_tasks);
static void print_help(void);

static char *progname = "multicoretest";

/* Structure to pass down data to threads */
typedef struct TaskData {
	int id;
} TaskData;

/*
 * Launch a task with a given ID
 */
static void
task(int id) {
	int i;
	double result = 0.0;

	printf("Task %d started\n", id);

	/* Execute all the operations */
	for (i = 0; i < NUMBER_OF_OPERATIONS; i++) {
		result = result + sin(i) * tan(i);
	}

	/* Print final result */
	printf("Task %d completed with result %e\n", id, result);
}

/*
 * Launch a certain number of tasks in serial, one by one
 */
static void
serial(int num_tasks) {
	int i;
	/* Launch all the operations one by one */
	for (i = 0; i < num_tasks; i++) {
		task(i);
	}
}


/*
 * Launch a threaded task
 */
static void *
threaded_task(void *data) {
	TaskData *taskData = (TaskData *) data;
	int id = taskData->id;

	printf("Thread %d started\n", id);
	task(id);
	printf("Thread %d done\n", id);
	pthread_exit(0);
}

/*
 * Launch in parallel the given number of tasks
 */
static void
parallel(int num_tasks)
{
	int num_threads = num_tasks;
	pthread_t thread[num_threads];
	TaskData *taskDatas[num_threads];
	int count;

	/* Build data sets for each thread */
	for (count = 0; count < num_threads; count++)
	{
		/* Allocate some memory */
		taskDatas[count] = (TaskData *) malloc(sizeof(TaskData));

		/* Then allocate data */
		taskDatas[count]->id = count;
	}

	/* Launch all the threads one by one */
	for (count = 0; count < num_threads; count++) {
		int rc;
		TaskData *data = taskDatas[count];

		/* Create the thread */
		printf("Creating thread %d\n", count);
		rc = pthread_create(&thread[count], NULL, threaded_task, data);

		/* Simply leave if any error at creation */
		if (rc) {
			printf("ERROR: return code from pthread_create() is %d\n", rc);
			exit(-1);
		}
	}

	/* Free all data sets */
	for (count = 0; count < num_threads; count++)
		free(taskDatas[count]);
}

/*
 * Print help
 */
static void
print_help(void) {
	printf("Usage: %s [ serial | parallel ] num_tasks\n", progname);
	exit(0);
}

/*
 * Main entry point
 */
int
main(int argc, char *argv[]) {
	int num_tasks;

	/* Print help if any problems in arguments */
	if (argc != 3)
		print_help();

	/* Allocate number of tasks */
	num_tasks = atoi(argv[2]);

	/* Check the first option, need nothing fancy here */
	if (!strcmp(argv[1], "serial"))
		serial(num_tasks);
	else if (!strcmp(argv[1], "parallel"))
		parallel(num_tasks);
	else
		print_help();

	printf("Main completed\n");
	pthread_exit(NULL);
}
