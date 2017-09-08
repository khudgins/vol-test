from yaml import dump
import getopt,sys

def generate_fio_job_array(container):
    pass
    # if container:
    #     return [{'fio':{'exec': 'docker', 'args': ['run', '-rm', 'fio-stress-test', '-v', 'storageos']}}]
    # else:
    #     return 

def generate_kernel_job_array(container):
    if container:
        return {'fio':{'exec': 'docker', 'args': ['run', '-rm', '-v', '${VOLNAME}:/data','storageos/kernel-compile' ]}}
    else:
        return 

def generate_db_stress_job_array(container):
    pass



def main():
    optlist, jobs = getopt.getopt(sys.argv[1:], 'c')
    
    container = False
    
    for o, a in optlist:
        if o == "-c":
            container = True

    job_file = {"description": "stress test job file"} 
    jobs_yaml = []

    if len(jobs) == 0:
        print "need at least one job to run"
        sys.exit(1)

    for job in jobs:
        if job == "kernel-compile":
            jobs_yaml.append(generate_kernel_job_array(container))
        elif job == "fio":
            jobs_yaml.append(generate_fio_job_array(container))
        else:
            jobs_yaml.append(generate_db_stress_job_array(container))
    
    job_file['jobs'] = jobs_yaml
    print dump(job_file)


if __name__ == "__main__":
    main()

