import requests
import csv
import urllib.parse
import time
import concurrent.futures
import statistics
import matplotlib.pyplot as plt
import os


def create_plot():
    times = [0.16025498912465, 0.17852628499525003, 0.20805281016225002, 0.22550336491289996, 0.28602220686720004, 0.34126617679044996]
    concurrent_reqs = [10, 20, 30, 40, 50, 60]

    plt.plot(concurrent_reqs, times)
    plt.title('Concurrent requests vs Request time')
    plt.xlabel('# concurrent requests')
    plt.ylabel('request time (s)')
    plt.savefig('req_time.png')
    #plt.show()

def send_req(url):
    start = time.perf_counter()
    json_res = requests.get(url = url)
    request_time = time.perf_counter() - start
    return request_time

# kubectl delete pod redis-master-0 -n search-api
def load_test():
    urls = []
    with open("../data/test_data_assessment.tsv") as fd:
        rd = csv.reader(fd, delimiter="\t", quotechar='"')
        res_dict = {}
        
        for row in rd:
            query = row[0]
            url_query = safe_string = urllib.parse.quote(query)
            url = f"{os.environ['NLB_URL']}/query/{url_query}"
            urls.append(url)

    urls = urls[:20000]
    req_times = []
    concurrent_reqs = 60
    with concurrent.futures.ThreadPoolExecutor(max_workers=concurrent_reqs) as executor:
        future_to_url = (executor.submit(send_req, url) for url in urls)
        for future in concurrent.futures.as_completed(future_to_url):
            try:
                data = future.result()
            except Exception as exc:
                data = str(type(exc))
            finally:
                req_times.append(data)

    avg_req_time = statistics.mean(req_times)
    print(f'avg req time for {concurrent_reqs} concurrent reqs is {avg_req_time}')

#load_test()
create_plot()