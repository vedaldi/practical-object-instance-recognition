#!/usr/bin/

from selenium import webdriver
import selenium.common.exceptions
from selenium.webdriver.common.keys import Keys
import time

def get_next_page_link(browser):
    pager_elements = browser.find_element_by_class_name("pager-items")

    pagelinks = pager_elements.find_elements_by_tag_name("a")

    for pagelink in pagelinks:
        if pagelink.text == "Next":
            return pagelink
    return None

def get_painters(browser):
    time.sleep(1)
    list_container = browser.find_element_by_id("listContainer")
    all_divs = list_container.find_elements_by_tag_name("div");
    painter_names = [];
    painter_urls = [];
    first_painting = [];
    for painterdiv in all_divs:
        if (painterdiv.get_attribute("id")).startswith("a-"):
            h2_elem = painterdiv.find_element_by_class_name("mr20")
            painter_name = h2_elem.text
            painter_names.append(painter_name)
            painter_url = h2_elem.find_element_by_tag_name("a").get_attribute("href");
            painter_urls.append(painter_url)

    return {'painter_names' : painter_names, 'painter_links' : painter_urls }


painting_style = "impressionism"

browser = webdriver.Firefox()
browser.implicitly_wait(30)
browser.get("http://www.wikipaintings.org/en/paintings-by-style/" +
            painting_style + "/1")

print browser.title

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
    browser.get(pgurl)
    painter_elements = get_painters(browser)
    painter_list = painter_list + painter_elements['painter_names']
    #painter_list = painter_list + painter_elemens
    painter_urls = painter_urls + painter_elements['painter_links']

paintings_artpage_list = []
paintings_name_list = []
paintings_src_list = []

painting_count = 0;

for painterurl in painter_urls:
    browser.get(painterurl)
    crt_painting_urls = []
    crt_painting_names = []
    crt_paintings_src = []
    # click on the current / style link to show the jcarousel
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
    for pp in range(1, total_paintings):
        crt_url = browser.current_url
        time.sleep()
        active_slide = browser.find_element_by_class_name("activeslide")
        artwork_link = browser.find_element_by_id("artworkLink")

        galleryData = browser.find_element_by_id("galleryData")
        pelem = galleryData.find_element_by_tag_name("p")
        ahref = pelem.find_element_by_tag_name("a")

        img_src = active_slide.find_element_by_tag_name("img").get_attribute("src")
        exclamation = img_src.find('!');
        if exclamation > -1:
            img_src = img_src[:exclamation]
        # Avoid copyright protected images
        if (img_src.lower() ==
            "http://cdnc.wikipaintings.org/zur/Global/Images/Global/FRAME-600x480.jpg".lower()):
            active_slide.click()
            continue
        crt_painting_urls.append(artwork_link)
        crt_painting_names.append(ahref.text)
        crt_paintings_src.append(img_src)
        print img_src
        active_slide.click()

    paintings_artpage_list.append(crt_painting_urls)
    paintings_name_list.append(crt_painting_names)
    paintings_src_list.append(crt_paintings_src)
    painting_count = painting_count + total_paintings


browser.close()

print "Found: %d painters " % len(painter_list)
print "Found: %d paintings" % painting_count
