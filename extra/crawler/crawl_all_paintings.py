#!/usr/bin/

import os
from selenium import webdriver
import time
import urllib
import sys
import string
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
    all_painter_divs = browser.find_elements_by_class_name("search-item")

    painter_names = [];
    painter_urls = [];

    print browser.current_url
    for painterdiv in all_painter_divs:
        ahref = painterdiv.find_element_by_tag_name("a");
        painter_name = ahref.text
        idx = painter_name.find('\n')
        painter_names.append(painter_name[:idx])
        painter_url = ahref.get_attribute("href");
        painter_urls.append(painter_url)

    return {'painter_names' : painter_names, 'painter_links' : painter_urls }


startAt = 0

DataDir = '/data/datasets/paintings/'

do_download = True
do_overwrite = False

if not os.path.exists(DataDir):
    os.mkdir(DataDir)


browser = webdriver.Firefox()
browser.implicitly_wait(60)

painter_list = []
painter_urls = []
for letter in string.uppercase[:26]:
    browser.get('http://www.wikipaintings.org/en/alphabet/' + letter)
    painter_elements = get_painters(browser)
    painter_list = painter_list + painter_elements['painter_names']
    #painter_list = painter_list + painter_elemens
    painter_urls = painter_urls + painter_elements['painter_links']

paintings_artpage_list = []
paintings_name_list = []
paintings_src_list = []


# write painters
with open(os.path.join(DataDir, 'all_painter_list.txt'), 'wb') as fp:
    for ii in range(0, len(painter_list)):
        fp.write((painter_urls[ii] + "\t" + painter_list[ii] + "\n").encode("UTF-8"))
    fp.closed

for ii in range(startAt, len(painter_urls)):
    idx_slash = painter_urls[ii].rfind('/') + 1
    painter_name = painter_urls[ii][idx_slash:]

    if os.path.exists(os.path.join(DataDir, 'lists', 'lst_' + painter_name + '_detailed.txt')):
        continue

    try:
        with open(os.path.join(DataDir, 'lists', 'lst_' + painter_name + '_detailed.txt'), 'wb') as fdet:
            with open(os.path.join(DataDir, 'lists', 'lst_' + painter_name + '_download.txt'), 'wb') as fdown:

                print str(ii) + "  " + painter_list[ii] + " " + painter_urls[ii]
                #hack to fit on the screen if painter portrait is larger
                browser.get(painter_urls[ii] + '/mode/all-paintings/')
                crt_painting_urls = []
                crt_painting_names = []
                crt_paintings_src = []
                # click on the current / style link to show the jcarousel
                try:
                    paintings_div = browser.find_element_by_id("paintings")

                    time.sleep(1)
                    # click on the first painting

                    container_a = paintings_div.find_element_by_class_name("mr20")
                    image_element = container_a.find_element_by_tag_name("img")
                    image_element.click()
                    time.sleep(1)

                    current_ul = browser.find_element_by_id("artistPaintings")
                    container_a = current_ul.find_element_by_class_name("rimage")
                    image_element = container_a.find_element_by_tag_name("img")
                    image_element.click()
                    print browser.current_url
                except ElementNotVisibleException:
                    # click on the first painting
                    paintings_div = browser.find_element_by_id("paintings")

                    time.sleep(1)
                    # click on the first painting

                    container_a = paintings_div.find_element_by_class_name("mr20")
                    image_element = container_a.find_element_by_tag_name("img")
                    image_element.click()
                    time.sleep(1)

                    current_ul = browser.find_element_by_id("artistPaintings")
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
                    nextslide_link = browser.find_element_by_id("nextslide")

                    crt_url = browser.current_url
                    idx_dash = crt_url.rfind('-') + 1

                    img_id = crt_url[idx_dash :]

                    galleryData = browser.find_element_by_id("galleryData")
                    pelems = galleryData.find_elements_by_tag_name("p")
                    pelem = pelems[0];
                    ahref = pelem.find_element_by_tag_name("a")
                    href_text = ahref.text
                    artwork_link = pelem.find_element_by_tag_name("a").get_attribute("href")

                    genre = "N/A"
                    style = "N/A"
                    year = "N/A"

                    for pelem in pelems:
                        if (pelem.text.lower().startswith("genre")):
                            genre = pelem.find_element_by_tag_name("span").text
                        if (pelem.text.lower().startswith("style")):
                            style = pelem.find_element_by_tag_name("span").text
                        if (pelem.text.lower().startswith("completion")):
                            year = pelem.find_element_by_tag_name("span").text


                    img_src = active_slide.find_element_by_tag_name("img").get_attribute("src")
                    exclamation = img_src.find('!');
                    if exclamation > -1:
                        img_src = img_src[:exclamation]
                    # Avoid copyright protected images
                    if (img_src.lower() ==
                        "http://cdnc.wikipaintings.org/zur/Global/Images/Global/FRAME-600x480.jpg".lower()):
                        continue
                    #there should be a smarter way to do this
                    fdet.write((img_id + u".jpg\t" + img_src + '\t' +
                                artwork_link + '\t' + href_text + '\t' +
                                painter_list[ii] + '\t' + style + '\t' + genre +
                                '\t' + year + '\n').encode('UTF-8'))
                    fdown.write(img_src + u'\n')

                    if (do_download):
                        dst_dir = os.path.join(DataDir, 'images', img_id[0:4])
                        dst_file = os.path.join(dst_dir, img_id + ".jpg")
                        if (not os.path.exists(dst_file) or do_overwrite):
                            if (not os.path.exists(dst_dir)):
                                os.mkdir(dst_dir)
                            urllib.urlretrieve(img_src, dst_file)

                    nextslide_link.click()

            fdown.closed
        fdet.closed
    except:
        print "Failed download for : " + painter_list[ii]
        traceback.print_exc(file=sys.stderr)

browser.close()

