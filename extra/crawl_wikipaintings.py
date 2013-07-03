#!/usr/bin/

import os
from selenium import webdriver
import time
import urllib
import sys
import traceback
from selenium.common.exceptions import ElementNotVisibleException


def get_next_page_link(browser):
    pager_elements = browser.find_element_by_class_name("pager-items")

    pagelinks = pager_elements.find_elements_by_tag_name("a")

    for pagelink in pagelinks:
        if pagelink.text == "Next":
            return pagelink
    return None

def get_painters(browser):
    list_container = browser.find_element_by_id("listContainer")
    all_divs = list_container.find_elements_by_tag_name("div");
    painter_names = [];
    painter_urls = [];
    first_painting = [];
    print browser.current_url
    for painterdiv in all_divs:
        div_id = painterdiv.get_attribute("id");
        if div_id.startswith("a-") and not div_id.endswith("-slider"):
            print painterdiv.get_attribute("id")
            h2_elem = painterdiv.find_element_by_class_name("mr20")
            painter_name = h2_elem.text
            painter_names.append(painter_name)
            painter_url = h2_elem.find_element_by_tag_name("a").get_attribute("href");
            painter_urls.append(painter_url)

    return {'painter_names' : painter_names, 'painter_links' : painter_urls }


def parse_args():
    if len(sys.argv) == 1:
        return
    try:
        for arg in sys.argv:
            if (arg.startswith('-')):
                tmp = arg[1:].lower()
                parts = tmp.split('=')
                if (parts[0] == 'datadir'):
                    _datadir = parts[1]
                elif (parts[0] == 'style'):
                    _painting_style = parts[1]
        return {'datadir' : _datadir, 'style': _painting_style}
    except:
        print "Usage: -datadir=<path_to_data> -style=<impressionism|post-impressionism|> "
        print "Please use a painting style from wikipaintings.org"
        return



argv = parse_args()

startAt = 0

if (argv == None):
    painting_style = "impressionism"
    DataDir = '/data/datasets/paintings/'
else:
    painting_style = argv['style']
    DataDir = argv['datadir']

do_download = True
do_overwrite = False

if not os.path.exists(DataDir):
    os.mkdir(DataDir)

DataDir = os.path.join(DataDir, painting_style)
if not os.path.exists(DataDir):
    os.mkdir(DataDir)


browser = webdriver.Firefox()
browser.implicitly_wait(60)
browser.get("http://www.wikipaintings.org/en/paintings-by-style/" +
            painting_style + "/1")

page_url_list = []
page_url_list.append(browser.current_url)
nextpage = get_next_page_link(browser)
attr = nextpage.get_attribute("href")

while attr != None:
    nextpage.click()
    page_url_list.append(browser.current_url)
    nextpage = get_next_page_link(browser)
    attr = nextpage.get_attribute("href")

painter_list = []
painter_urls = []
for pgurl in page_url_list:
    time.sleep(2)
    browser.get(pgurl)
    painter_elements = get_painters(browser)
    painter_list = painter_list + painter_elements['painter_names']
    #painter_list = painter_list + painter_elemens
    painter_urls = painter_urls + painter_elements['painter_links']

paintings_artpage_list = []
paintings_name_list = []
paintings_src_list = []

painting_count = 0;

# write painters
with open(os.path.join(DataDir, painting_style + '_painter_list.txt'), 'wb') as fp:
    for ii in range(0, len(painter_list)):
        fp.write((painter_list[ii] + "\n").encode("UTF-8"))
    fp.closed


for ii in range(startAt, len(painter_urls)):
    idx_slash = painter_urls[ii].rfind('/') + 1
    painter_name = painter_urls[ii][idx_slash:]

    try:
        with open(os.path.join(DataDir, 'lst_' + str(ii).zfill(4) + '_' + painter_name + '_detailed.txt'), 'wb') as fdet:
            with open(os.path.join(DataDir, 'lst_' + str(ii).zfill(4) + '_' + painter_name + '_download.txt'), 'wb') as fdown:

                print str(ii) + "  " + painter_list[ii] + " " + painter_urls[ii]
                #hack to fit on the screen if painter portrait is larger
                browser.get(painter_urls[ii])
                crt_painting_urls = []
                crt_painting_names = []
                crt_paintings_src = []
                # click on the current / style link to show the jcarousel
                try:
                    current_list = browser.find_element_by_id("link-" + painting_style)
                    current_list.click()
                    time.sleep(1)
                    # click on the first painting
                    current_ul = browser.find_element_by_id("carousel-" + painting_style)
                    container_a = current_ul.find_element_by_class_name("rimage")
                    image_element = container_a.find_element_by_tag_name("img")
                    image_element.click()
                except ElementNotVisibleException:
                    current_list = browser.find_element_by_id("link-" + painting_style)
                    current_list.click()
                    time.sleep(1)
                    # click on the first painting
                    current_ul = browser.find_element_by_id("carousel-" + painting_style)
                    container_a = current_ul.find_element_by_class_name("rimage")
                    image_element = container_a.find_element_by_tag_name("img")
                    image_element.click()
                time.sleep(1)

                span_total = browser.find_element_by_class_name("totalslides")
                total_paintings_str = span_total.get_attribute("innerHTML")
                try:
                    total_paintings = int(total_paintings_str)
                except:
                    total_paintings_str = span_total.get_attribute("innerHTML")
                    total_paintings = int(total_paintings_str)

                for pp in range(0, total_paintings):
                    time.sleep(1)
                    active_slide = browser.find_element_by_class_name("activeslide")

                    crt_url = browser.current_url
                    idx_dash = crt_url.rfind('-') + 1

                    img_id = crt_url[idx_dash :]

                    galleryData = browser.find_element_by_id("galleryData")
                    pelem = galleryData.find_element_by_tag_name("p")
                    ahref = pelem.find_element_by_tag_name("a")
                    href_text = ahref.text
                    artwork_link = pelem.find_element_by_tag_name("a").get_attribute("href")

                    img_src = active_slide.find_element_by_tag_name("img").get_attribute("src")
                    exclamation = img_src.find('!');
                    if exclamation > -1:
                        img_src = img_src[:exclamation]
                    # Avoid copyright protected images
                    if (img_src.lower() ==
                        "http://cdnc.wikipaintings.org/zur/Global/Images/Global/FRAME-600x480.jpg".lower()):
                        active_slide.click()
                        continue
                    #there should be a smarter way to do this
                    fdet.write((img_id + u".jpg\t" + img_src + '\t' + artwork_link + '\t' + href_text + '\n').encode('UTF-8'))
                    fdown.write(img_src + u'\n')

                    if (do_download):
                        dst_path = os.path.join(DataDir, img_id + ".jpg")
                        if (not os.path.exists(dst_path) or do_overwrite):
                            urllib.urlretrieve(img_src, dst_path)

                    active_slide.click()

            fdown.closed
        fdet.closed
    except:
        print "Failed download for : " + painter_list[ii]


browser.close()
