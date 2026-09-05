package com.azkar.repository;

import com.azkar.model.Zikr;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ZikrRepository extends JpaRepository<Zikr, Long> {
    List<Zikr> findByCategoryIdOrderByItemOrderAsc(Long categoryId);
    List<Zikr> findByCategoryCodeOrderByItemOrderAsc(String categoryCode);
    List<Zikr> findByIsFavoriteTrueOrderByItemOrderAsc();

    @Query("SELECT z FROM Zikr z WHERE LOWER(z.textAr) LIKE LOWER(CONCAT('%', :query, '%')) OR LOWER(z.fadlVirtue) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Zikr> searchAzkar(@Param("query") String query);
}
