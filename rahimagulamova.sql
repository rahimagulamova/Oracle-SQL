-- 1. Abonentlərin yaş qrupuna görə və cinsiyyətə görə bölgüsünü göstər:
--    Yaş qrupları aşağıdakı şəkildədi
--    18 və aşağı
--    19-30
--    31-50
--    51 və yuxarı
--    Ekrana yaş aralığı,cins və say haqqında informasiyalar çıxsın.

SELECT
    CASE 
        WHEN age <= 18 THEN '18 və aşağı'
        WHEN age BETWEEN 19 AND 30 THEN '19-30'
        WHEN age BETWEEN 31 AND 50 THEN '31-50'
        ELSE '51 və yuxarı'
    END AS age_group,
    gender,
    COUNT(*) AS count
FROM
    subscribers
GROUP BY
    age_group, gender
ORDER BY
    age_group, gender;


--2.Hər abonent üçün son ödəniş tarixini və məbləğini göstər: 
--    Ekrana Ad, soyad, son ödəniş tarixi, məbləği və ödənişin üsulu haqqında informasiyalar çıxsın.
 SELECT 
    s.first_name AS Ad,
    s.last_name AS Soyad,
    p.payment_date AS Son_ödəniş_tarixi,
    p.amount AS Məbləğ,
    p.payment_method AS Ödəniş_usulu
FROM 
    subscribers s
JOIN 
    payments p ON s.subscriber_id = p.subscriber_id
WHERE 
    p.payment_date = (
        SELECT MAX(payment_date) 
        FROM payments 
        WHERE subscriber_id = s.subscriber_id
    )
ORDER BY 
    p.payment_date DESC;
           
-- 3.Aktiv xidmətlər üzrə abonentlərin sayını və ümumi ödəniş məbləğini göstər:
--    Ekrana xidmətin adı,abonentlərin sayını və ümumi ödəniş məbləği haqqında informasiyalar çıxsın. 
SELECT 
    s.service_name AS Xidmət_adi,
    COUNT(ss.subscriber_id) AS Abonent_sayı,
    SUM(p.amount) AS Ümumi_ödəmə_məbləği
FROM 
    services s
JOIN 
    subscriber_services ss ON s.service_id = ss.service_id
JOIN 
    payments p ON ss.subscriber_id = p.subscriber_id
WHERE 
    ss.is_active = 1  -- Yalnız aktiv xidmətlər üçün
GROUP BY 
    s.service_name
ORDER BY 
    Abonent_sayı DESC;
     
-- 4.Hər abonent üçün edilən zənglərin sayını və ümumi zəng müddətini göstər:
--    Ekrana ad, soyad, abonent üçün edilən zənglərin sayını, ümumi zəng müddətini, zəngin tipi haqqında informasiyalar çıxsın.
SELECT 
    s.first_name AS Ad,
    s.last_name AS Soyad,
    COUNT(c.call_id) AS Zənglərin_sayı,
    SUM(c.call_duration) AS Ümumi_zəng_müddəti,
    c.call_type AS Zəngin_tipi
FROM 
    subscribers s
JOIN 
    calls c ON s.subscriber_id = c.subscriber_id
GROUP BY 
    s.first_name, s.last_name, c.call_type
ORDER BY 
    Zənglərin_sayı DESC;
 
--5.Hər abonent üçün tarifə görə aylıq ödədikləri məbləği və zənglərin sayını göstər:
--    Ekrana ad, soyad,tarifə görə aylıq ödədikləri məbləğ və zənglərin sayı haqqında informasiyalar çıxsın. 
SELECT 
    s.first_name AS Ad,
    s.last_name AS Soyad,
    t.tariff_name AS Tarif,
    SUM(p.amount) AS Aylıq_ödəmə_məbləği,
    COUNT(c.call_id) AS Zənglərin_sayı
FROM 
    subscribers s
JOIN 
    subscriber_tariffs st ON s.subscriber_id = st.subscriber_id
JOIN 
    tariffs t ON st.tariff_id = t.tariff_id
JOIN 
    payments p ON s.subscriber_id = p.subscriber_id
JOIN 
    calls c ON s.subscriber_id = c.subscriber_id
WHERE 
    p.payment_date BETWEEN DATE_SUB(NOW(), INTERVAL 1 MONTH) AND NOW()  -- Yalnız son 1 ayın ödənişləri
GROUP BY 
    s.first_name, s.last_name, t.tariff_name
ORDER BY 
    Aylıq_ödəmə_məbləği DESC;
         
--6.Zənglərin növünə görə abonentlərin sayını və ümumi zəng müddətini göstər:
 SELECT 
    c.call_type AS Zəngin_növu,
    COUNT(DISTINCT c.subscriber_id) AS Abonent_sayı,
    SUM(c.call_duration) AS Ümumi_zəng_müddəti
FROM 
    calls c
GROUP BY 
    c.call_type
ORDER BY 
    Abonent_sayı DESC;
           
--7.Hər tarif üzrə abonentlərin orta yaşını göstər:
SELECT 
    t.tariff_name AS Tarif,
    AVG(YEAR(CURDATE()) - YEAR(s.birth_date)) AS Orta_yaş
FROM 
    subscribers s
JOIN 
    subscriber_tariffs st ON s.subscriber_id = st.subscriber_id
JOIN 
    tariffs t ON st.tariff_id = t.tariff_id
GROUP BY 
    t.tariff_name
ORDER BY 
    Orta_yaş DESC;
              
--8.Son 6 ayda edilən ödənişlərin məbləğini və xidmətlərin sayını abonentlər üzrə göstər.
--    Ekrana abonentin adı, abonentin soyadı, xidmətlərin sayı və 6 ayda edilən ödənişlərin məbləği haqqında informasiyalar çıxsın.
SELECT 
    s.first_name AS Ad,
    s.last_name AS Soyad,
    COUNT(DISTINCT ss.service_id) AS Xidmətlərin_sayı,
    SUM(p.amount) AS 6_aylıq_ödəmə_məbləği
FROM 
    subscribers s
JOIN 
    subscriber_services ss ON s.subscriber_id = ss.subscriber_id
JOIN 
    payments p ON s.subscriber_id = p.subscriber_id
WHERE 
    p.payment_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 6 MONTH) AND CURDATE()
GROUP BY 
    s.first_name, s.last_name
ORDER BY 
    6_aylıq_ödəmə_məbləği DESC;
    
--9.Hər şikayət növü üzrə həll olunma müddətinin orta dəyərini və şikayət sayını göstər:
SELECT 
    c.complaint_type AS Şikayət_növu,
    COUNT(c.complaint_id) AS Şikayət_sayı,
    AVG(DATEDIFF(c.resolution_date, c.complaint_date)) AS Orta_həll_müddəti
FROM 
    complaints c
WHERE 
    c.resolution_date IS NOT NULL  -- Yalnız həll edilmiş şikayətlər
GROUP BY 
    c.complaint_type
ORDER BY 
    Orta_həll_müddəti ASC;
 
--10. Hər abonent üçün son 12 ayda göndərilən SMS-lərin sayını və SMS məzmununu göstər:
SELECT 
    s.first_name AS Ad,
    s.last_name AS Soyad,
    COUNT(sm.sms_id) AS Sms_sayı,
    GROUP_CONCAT(sm.sms_content SEPARATOR '; ') AS Sms_məzmunu
FROM 
    subscribers s
JOIN 
    sms sm ON s.subscriber_id = sm.subscriber_id
WHERE 
    sm.sent_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 12 MONTH) AND CURDATE()
GROUP BY 
    s.first_name, s.last_name
ORDER BY 
    Sms_sayı DESC;
     
--11.Hər abonent üçün edilən zənglərin ümumi müddətini və ödəniş məlumatlarını göstər:    
--   Ekrana abonentin adı, abonentin soyadı, zənglərin ümumi müddətini ödəniş məlumatları haqqında informasiyalar çıxsın. 
SELECT 
    s.first_name AS Ad,
    s.last_name AS Soyad,
    SUM(c.call_duration) AS Zənglərin_ümumi_müddəti,
    SUM(p.amount) AS Ümumi_ödəmə_məbləği
FROM 
    subscribers s
LEFT JOIN 
    calls c ON s.subscriber_id = c.subscriber_id
LEFT JOIN 
    payments p ON s.subscriber_id = p.subscriber_id
GROUP BY 
    s.first_name, s.last_name
ORDER BY 
    Zənglərin_ümumi_müddəti DESC;
      
--12. Hər tarif üzrə abonentlərin aylıq ödədikləri məbləğin orta dəyərini və zənglərin sayını göstər:
--   Ekrana tarif adı, abonentlərin aylıq ödədikləri məbləğin orta dəyəri və zənglərin sayı haqqında informasiyalar çıxsın. 
SELECT 
    t.tariff_name AS Tarif_adi,
    AVG(p.amount) AS Orta_ödəmə_məbləği,
    COUNT(c.call_id) AS Zənglərin_sayı
FROM 
    tariffs t
JOIN 
    subscriber_tariffs st ON t.tariff_id = st.tariff_id
JOIN 
    subscribers s ON st.subscriber_id = s.subscriber_id
LEFT JOIN 
    payments p ON s.subscriber_id = p.subscriber_id
LEFT JOIN 
    calls c ON s.subscriber_id = c.subscriber_id
GROUP BY 
    t.tariff_name
ORDER BY 
    Orta_ödəmə_məbləği DESC;

--13. Hər abonent üçün son 12 ayda göndərilən SMS-lərin məzmununu və göndərilən SMS növlərini göstər:
--   Ekrana abonentin adı, soyadı, son 12 ayda göndərilən SMS-lərin məzmununu və göndərilən SMS növləri haqqında informasiyalar çıxsın.  
SELECT 
    s.first_name AS Ad,
    s.last_name AS Soyad,
    GROUP_CONCAT(sm.sms_content SEPARATOR '; ') AS Sms_məzmunu,
    GROUP_CONCAT(DISTINCT sm.sms_type SEPARATOR '; ') AS Sms_növləri
FROM 
    subscribers s
JOIN 
    sms sm ON s.subscriber_id = sm.subscriber_id
WHERE 
    sm.sent_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 12 MONTH) AND CURDATE()
GROUP BY 
    s.first_name, s.last_name
ORDER BY 
    s.last_name, s.first_name;
      
-- 14. Hər abonent üçün son 6 ayda edilən ödənişlərin məbləğini və xidmətlərin sayını göstər:
--   Ekrana abonentin adı, soyadı, son 6 ayda edilən ödənişlərin məbləğini və xidmətlərin sayı haqqında informasiyalar çıxsın.
SELECT 
    s.first_name AS Ad,
    s.last_name AS Soyad,
    SUM(p.amount) AS Son_6_ayda_ödəmə_məbləği,
    COUNT(DISTINCT ss.service_id) AS Xidmətlərin_sayı
FROM 
    subscribers s
LEFT JOIN 
    payments p ON s.subscriber_id = p.subscriber_id
LEFT JOIN 
    subscriber_services ss ON s.subscriber_id = ss.subscriber_id
WHERE 
    p.payment_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 6 MONTH) AND CURDATE()
GROUP BY 
    s.first_name, s.last_name
ORDER BY 
    Son_6_ayda_ödəmə_məbləği DESC;
       
-- 15. Hər abonent üçün ödənişlər və şikayətlərin məbləğini göstər:
--   Ekrana abonentin adı, soyadı, hər abonent üçün ödənişlər və şikayətlərin sayı haqqında informasiyalar çıxsın. 
 SELECT 
    s.first_name AS Ad,
    s.last_name AS Soyad,
    COUNT(DISTINCT p.payment_id) AS Ödənişlərin_sayı,
    COUNT(DISTINCT c.complaint_id) AS Şikayətlərin_sayı
FROM 
    subscribers s
LEFT JOIN 
    payments p ON s.subscriber_id = p.subscriber_id
LEFT JOIN 
    complaints c ON s.subscriber_id = c.subscriber_id
GROUP BY 
    s.first_name, s.last_name
ORDER BY 
    s.last_name, s.first_name;
     
-- 16. Hər tarif üzrə abonentlərin yaş qruplarına görə və aylıq ödədikləri məbləğin orta dəyərini göstər:
--     Ekrana tarifin adı, yaş qrupları, aylıq ödədikləri məbləğin orta dəyəri haqqında informasiyalar çıxsın.   
 SELECT 
    t.tariff_name AS Tarif_adi,
    CASE 
        WHEN YEAR(CURDATE()) - YEAR(s.birth_date) <= 18 THEN '18 və aşağı'
        WHEN YEAR(CURDATE()) - YEAR(s.birth_date) BETWEEN 19 AND 30 THEN '19-30'
        WHEN YEAR(CURDATE()) - YEAR(s.birth_date) BETWEEN 31 AND 50 THEN '31-50'
        ELSE '51 və yuxarı'
    END AS Yaş_qrupu,
    AVG(p.amount) AS Orta_ödəmə_məbləği
FROM 
    subscribers s
JOIN 
    subscriber_tariffs st ON s.subscriber_id = st.subscriber_id
JOIN 
    tariffs t ON st.tariff_id = t.tariff_id
LEFT JOIN 
    payments p ON s.subscriber_id = p.subscriber_id
GROUP BY 
    t.tariff_name, Yaş_qrupu
ORDER BY 
    t.tariff_name, Yaş_qrupu;
      
-- 17. Hər abonentin ümumi ödədiyi məbləği və onların ödədikləri məbləğin tariflərin ortalama ödəmə məbləğindən yüksək olub 
--     olmadığını göstərən sorğu:
 WITH AveragePayments AS (
    SELECT 
        t.tariff_id,
        AVG(p.amount) AS Orta_ödəmə_məbləği
    FROM 
        tariffs t
    LEFT JOIN 
        subscriber_tariffs st ON t.tariff_id = st.tariff_id
    LEFT JOIN 
        payments p ON st.subscriber_id = p.subscriber_id
    GROUP BY 
        t.tariff_id
)

SELECT 
    s.first_name AS Ad,
    s.last_name AS Soyad,
    SUM(p.amount) AS Ümumi_ödəmə_məbləği,
    CASE 
        WHEN SUM(p.amount) > ap.Orta_ödəmə_məbləği THEN 'Yüksək'
        ELSE 'Aşağı'
    END AS Ödəniş_statusu
FROM 
    subscribers s
LEFT JOIN 
    payments p ON s.subscriber_id = p.subscriber_id
LEFT JOIN 
    subscriber_tariffs st ON s.subscriber_id = st.subscriber_id
LEFT JOIN 
    AveragePayments ap ON st.tariff_id = ap.tariff_id
GROUP BY 
    s.first_name, s.last_name, ap.Orta_ödəmə_məbləği
ORDER BY 
    Ümumi_ödəmə_məbləği DESC;
      
-- 18. Hər abonentin zənglərin ümumi müddətini və onların zəng müddətinin abonentin yaş qrupunun ortalama zəng müddətindən 
--     yüksək olub olmadığını göstərən sorğu:             
WITH AgeGroupCalls AS (
    SELECT 
        s.subscriber_id,
        SUM(c.call_duration) AS Ümumi_zəng_müddəti,
        CASE 
            WHEN YEAR(CURDATE()) - YEAR(s.birth_date) <= 18 THEN '18 və aşağı'
            WHEN YEAR(CURDATE()) - YEAR(s.birth_date) BETWEEN 19 AND 30 THEN '19-30'
            WHEN YEAR(CURDATE()) - YEAR(s.birth_date) BETWEEN 31 AND 50 THEN '31-50'
            ELSE '51 və yuxarı'
        END AS Yaş_qrupu
    FROM 
        subscribers s
    LEFT JOIN 
        calls c ON s.subscriber_id = c.subscriber_id
    GROUP BY 
        s.subscriber_id, Yaş_qrupu
)
   

      


      

     




